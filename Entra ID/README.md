# Read me

# Microsoft Entra - ID

Contains code related to Microsoft Entra Id

## Disclaimer

The code and documentation in this repository are provided "as is" without warranty of any kind, either express or implied, including but not limited to the implied warranties of merchantability and fitness for a particular purpose. Use at your own risk.

## Table of Contents

### PowerShell
- Blog post: [Configure EmployeeHireDate and EmployeeLeaveDateTime in Active Directory to be used with Microsoft Entra ID Governance](https://www.christianfrohn.dk/2024/05/02/configure-employeehiredate-and-employeeleavedatetime-in-active-directory-to-be-used-with-microsoft-entra-id-governance/)
  - [GetEmployeeHireOrLeaveDateTime.ps1](https://github.com/ChrFrohn/Entra/blob/main/Entra%20ID/GetEmployeeHireOrLeaveDateTime.ps1) - Script to get employee hire or leave date and time using HTTP requests.
  - [GetEmployeeHireOrLeaveDateTime2.ps1](https://github.com/ChrFrohn/Entra/blob/main/Entra%20ID/GetEmployeeHireOrLeaveDateTime2.ps1) - Script to get employee hire or leave date and time using PowerShell SDK
  - [Set-EmployeeLeaveDateTime.ps1](https://github.com/ChrFrohn/Entra/blob/main/Entra%20ID/Set-EmployeeLeaveDateTime.ps1) - Script to set employee leave date and time
- [GetEntraGroupId.ps1](https://github.com/ChrFrohn/Entra/blob/main/Entra%20ID/GetEntraGroupId.ps1) - Script to get Entra group ID
- [Set-EmployeeDivision.ps1](https://github.com/ChrFrohn/Entra/blob/main/Entra%20ID/Set-EmployeeDivision.ps1) - Script to set employee division
- [Get-MemberOfDynamicGroups.ps1](https://github.com/ChrFrohn/Entra/blob/main/Entra%20ID/Get-MemberOfDynamicGroups.ps1) - Script to list dynamic membership groups that use the memberOf operator, which is retired after November 3, 2026
- [Get-SmsVoiceRetirementReadiness.ps1](https://github.com/ChrFrohn/Entra/blob/main/Entra%20ID/Get-SmsVoiceRetirementReadiness.ps1) - Script to export authentication method registration details for active users and classify passkey readiness ahead of the SMS/Voice retirement on February 1, 2027
