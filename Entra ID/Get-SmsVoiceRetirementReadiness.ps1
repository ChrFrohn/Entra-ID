<#
.SYNOPSIS
 Exports authentication method registration details for active, enabled member users.

.DESCRIPTION
 Connects to Microsoft Graph, retrieves the authentication methods registration report,
 and filters it down to enabled member accounts with an interactive sign-in within the
 last 12 months. Each user is classified for passkey readiness ahead of the SMS/Voice
 retirement (2027-02-01), and the result is exported to a CSV file.

.PARAMETER TenantId
 The Entra ID tenant ID to connect to. If not supplied, the script prompts for it.

.EXAMPLE
 .\Export-ActiveUserAuthMethods.ps1

.EXAMPLE
 .\Export-ActiveUserAuthMethods.ps1 -TenantId "e6e68e14-0c3f-413b-abdf-8b1f8f0ade02"

.NOTES
 Author: Christian Frohn
 https://www.linkedin.com/in/frohn/
 Version: 1.0

 Prerequisites:
 - Microsoft.Graph.Reports module
 - Microsoft.Graph.Users module

 Required Microsoft Graph API Permissions:
 - AuditLog.Read.All: Read authentication methods registration report and sign-in activity
 - User.Read.All: Read user profiles

.LINK
 https://learn.microsoft.com/en-us/entra/identity/authentication/howto-authentication-methods-activity
 https://learn.microsoft.com/en-us/entra/identity/authentication/concept-sms-voice-retirement
#>

param(
 [string]$TenantId
)

## To be edited for your needs:
$CutoffMonths = 12 # How many months back a user must have an interactive sign-in to be considered active
$ExportPath = Join-Path -Path $PSScriptRoot -ChildPath ("AuthMethods-ActiveUsers-{0}.csv" -f (Get-Date -Format "yyyy-MM-dd"))

if ([string]::IsNullOrWhiteSpace($TenantId))
{
 $TenantId = Read-Host -Prompt "Enter Tenant ID"
}

Connect-MgGraph -TenantId $TenantId -Scopes "AuditLog.Read.All", "User.Read.All" -NoWelcome

Write-Host "Retrieving authentication methods registration report..." -ForegroundColor Yellow

$RegistrationDetails = Get-MgReportAuthenticationMethodUserRegistrationDetail -All

Write-Host "Retrieving enabled member users with sign-in activity..." -ForegroundColor Yellow

# signInActivity does not support $filter combined with other filterable properties, so the date check is done client-side
$CutoffDate = (Get-Date).AddMonths(-$CutoffMonths)

$AllUsers = Get-MgUser -All -Filter "accountEnabled eq true and userType eq 'Member'" -Property Id, UserPrincipalName, AccountEnabled, UserType, SignInActivity

$ActiveUsers = @()

Foreach ($User in $AllUsers)
{
 if ($User.SignInActivity.LastSignInDateTime -and $User.SignInActivity.LastSignInDateTime -ge $CutoffDate)
 {
  $ActiveUsers += $User
 }
}

$ActiveUserIds = $ActiveUsers.Id

$ActiveRegistrationDetails = $RegistrationDetails | Where-Object { $_.Id -in $ActiveUserIds }

Write-Host "Classifying passkey readiness..." -ForegroundColor Yellow

$ClassifiedRegistrationDetails = @()

Foreach ($Detail in $ActiveRegistrationDetails)
{
 $MethodsJoined = $Detail.MethodsRegistered -join ";"

 # First match wins, mirroring the PasskeyStatus formula in Forumlars.md
 $PasskeyStatus = "5 - No MFA method - needs passkey"

 if ($MethodsJoined -match "passKey")
 {
  $PasskeyStatus = "1 - Passkey ready"
 }
 elseif ($MethodsJoined -match "windowsHelloForBusiness" -or $MethodsJoined -match "certificate")
 {
  $PasskeyStatus = "2 - Phishing-resistant, no passkey"
 }
 elseif ($MethodsJoined -match "Phone" -and $MethodsJoined -notmatch "microsoftAuthenticator" -and $MethodsJoined -notmatch "OneTimePasscode")
 {
  $PasskeyStatus = "3 - CRITICAL - SMS/Voice only"
 }
 elseif ($Detail.IsMfaCapable)
 {
  $PasskeyStatus = "4 - MFA registered, needs passkey"
 }

 $BlockedAfterRetirement = if ($PasskeyStatus.StartsWith("3")) { "Yes" } else { "No" }

 $RecommendedAction = switch -Wildcard ($PasskeyStatus)
 {
  "1*" { "None - monitor only" }
  "2*" { "Register passkey when convenient" }
  "3*" { "Priority 1 - passkey registration campaign before 2027-02-01" }
  "4*" { "Priority 2 - add to passkey registration campaign" }
  "5*" { "Priority 3 - onboard via TAP + passkey registration" }
 }

 $ClassifiedRegistrationDetails += [PSCustomObject]@{
  UserPrincipalName      = $Detail.UserPrincipalName
  UserDisplayName        = $Detail.UserDisplayName
  UserType               = $Detail.UserType
  IsAdmin                = $Detail.IsAdmin
  IsMfaCapable           = $Detail.IsMfaCapable
  IsMfaRegistered        = $Detail.IsMfaRegistered
  IsPasswordlessCapable  = $Detail.IsPasswordlessCapable
  IsSsprCapable          = $Detail.IsSsprCapable
  IsSsprEnabled          = $Detail.IsSsprEnabled
  IsSsprRegistered       = $Detail.IsSsprRegistered
  MethodsRegistered      = $MethodsJoined
  PasskeyStatus          = $PasskeyStatus
  'BlockedAfter2027-02-01' = $BlockedAfterRetirement
  RecommendedAction      = $RecommendedAction
 }
}

Write-Host ("Exporting {0} active user registration records..." -f $ClassifiedRegistrationDetails.Count) -ForegroundColor Yellow

$ClassifiedRegistrationDetails | Export-Csv -Path $ExportPath -NoTypeInformation

Write-Host ("Export complete: {0}" -f $ExportPath) -ForegroundColor Cyan