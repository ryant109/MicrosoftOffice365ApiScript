# MicrosoftOffice365ApiScript
A script for Microsoft Api to connect to unified audit logs


## How to use the script:
Please clone this repo and place it in your PowerShell Modules folder. 

From here you should be able to include this script into your powershell script by typing:
Import-Module ConnectAuditLogs

The office 365 api requires you to start a subscription to the logs you wish to get information about. So the first command you will want to run is the following: 
```powershell 
getToken -resource "https://manage.office.com" -tenantGUID "tenant GUID" -client_id "id of the app registration" -client_secret "clientSecret of App registration" -loginUrl "https://login.microsoftonline.com/" -tenantdomain "your tenant domainname";

startOffice365Subscription -resource "https://manage.office.com" -tenantGUID "tenant GUID" -headerParams "your header params" -subscription "the subscription you want to subscribe to i.e Audit.General"
```


