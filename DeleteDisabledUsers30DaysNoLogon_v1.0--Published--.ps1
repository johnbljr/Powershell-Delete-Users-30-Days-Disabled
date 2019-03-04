<#
------------------------------------------------------------
Author: John Leger
Date: January 15, 2019
Powershell Version Built/Tested on: 5.1
Title: Delete Disabled Users Older than 30 Days with No Logon
Website: https://github.com/johnbljr
License: GNU General Public License v3.0
------------------------------------------------------------
#>   

#------------------------------------------------------------
# Imports the needed Active Directory PowerShell Module 
#------------------------------------------------------------

Import-Module ActiveDirectory

#------------------------------------------------------------
# Set the number of days since last logon
#------------------------------------------------------------
$DaysInactive = 30
$InactiveDate = (Get-Date).Adddays(-($DaysInactive))
  
#------------------------------------------------------------
# FIND INACTIVE/Disabled USERS that are not service accounts.
#------------------------------------------------------------
# Get AD Users that haven't logged on in $DaysInactive and are not Service Accounts
$Users = Get-ADUser -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $false -and SamAccountName -notlike "*svc*" } -Properties LastLogonDate | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, SAMAccountName, Name, LastLogonDate, DistinguishedName

#------------------------------------------------------------
# REPORTING
#------------------------------------------------------------
# Export results to CSV
$Users | Export-Csv "\\server\Sharefolder\Disabled\DeleteDisabledUsers $((Get-Date).ToString('MM-dd-yyyy_hh-mm-ss')).csv" -NoTypeInformation

#------------------------------------------------------------
# INACTIVE USER MANAGEMENT
#------------------------------------------------------------
# Delete Disabled Users
ForEach ($Item in $Users){
  Remove-ADUser -Identity $Item.DistinguishedName -Confirm:$false
  Write-Output "$($Item.Username) - Deleted"

#------------------------------------------------------------
# Sends email to #### group with attachment
#------------------------------------------------------------

$ToGroupDL = "Systems Reporting <systems_reporting@domain.com>"
$From = "IT Group No Reply <IT_No_Reply@domain.com"
$Subject = "Deleted Users older than 30 days"
$Body = "Please see the latest attached report for disabled users that have been deleted. If you have any questions please contact the help desk."

Send-MailMessage -From $From -Subject $Subject  -To $ToGroupDL -Attachments $Location -Body $Body -SmtpServer $SMTPServer
