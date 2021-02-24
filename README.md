# MicrosoftOffice365ApiScript
A script for Microsoft Api to connect to unified audit logs


## How to use the script:
Please clone this repo and place it in your PowerShell Modules folder. 

From here you should be able to include this script into your powershell script by typing:
Import-Module ConnectAuditLogs

The office 365 api requires you to start a subscription to the logs you wish to get information about. So the first command you will want to run is the following: 
```powershell 
$headerparams  = getToken -resource "https://manage.office.com" -tenantGUID "tenant GUID" -client_id "id of the app registration" -client_secret "clientSecret of App registration" -loginUrl "https://login.microsoftonline.com/" -tenantdomain "your tenant domainname";

startOffice365Subscription -resource "https://manage.office.com" -tenantGUID "tenant GUID" -headerParams $headerparams -subscription "the subscription you want to subscribe to i.e Audit.General"
```
Now you can check your list of subscriptions with the following command:
```powershell 
$listofsubscriptions = checkOffice365Subscriptions -resource -resource "https://manage.office.com" -tenantGUID "tenant GUID" -headerParams $headerParams
```
This should return a list of subscriptions you have created.

This API returns content blobs based on 24 hour periods you need to retreive the ID of the blob with the following command:
```powershell 
$contentType = getOffice365ContentTypeFromSubscription -resource "https://manage.office.com" -tenantGUID "tenant GUID" -headerParams $headerParams -subscription "Audit.General <or other subscription";
```
you can now use this content type ID to get the logs for the period with the following: 
```powershell 
$logs = getOffice365LogsFromContent -resource "https://manage.office.com" -tenantGUID "tenant GUID" -headerParams $headerParams -contentType $contentType -workload "PowerApps <or any other workload";
```





