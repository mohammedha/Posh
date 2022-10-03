
## Grant the service account Impersonation rights

## On the “Execution Policy Change” question type “Y” and press “Enter”.
Set-ExecutionPolicy RemoteSigned

## This will prompt a pop-up asking for credentials.
## Enter the user name and password for your Microsoft 365 admin account and click “Ok”.
$UserCredential = Get-Credential

## Create session
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

## Import session
Import-PSSession $Session

## Create a management scope
## which will be used in the next step to restrict the impersonation right. The below command will limit the scope to resources (room and equipment mailboxes):
New-eoManagementScope -Name "ResourceMailboxes" -RecipientRestrictionFilter { RecipientTypeDetails -eq "RoomMailbox" -or RecipientTypeDetails -eq "EquipmentMailbox" -or PrimarySmtpAddress -eq "Evoko.Service@zaha-hadid.com" }

## Grant the service account Impersonation 
New-eoManagementRoleAssignment –Name "ResourceImpersonation" –Role ApplicationImpersonation -User Evoko.Service@zaha-hadid.com –CustomRecipientWriteScope "ResourceMailboxes"

## Confirm that impersonation has been granted
Get-eoManagementRoleAssignment -Role “ApplicationImpersonation” -GetEffectiveUsers

## Disconnect from the Power-shell session
Remove-PSSession $Session


LW43clq9ibgUnK9nwvHy