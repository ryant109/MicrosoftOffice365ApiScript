
#Gets a token from the environment.
function getOffice365Token
{
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$resource,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$client_ID,
        [Parameter(Mandatory=$true, Position=2)]
        [string]$client_secret,
        [Parameter(Mandatory=$true, Position=3)]
        [string]$loginUrl,
        [Parameter(Mandatory=$true, Position=4)]
        [string]$tenantdomain
    )

    $body = @{grant_type="client_credentials";resource=$resource;client_id=$ClientID;client_secret=$ClientSecret}
    $postString = -join($loginURL,"/",$tenantdomain,"/oauth2/token?api-version=1.0");
    $oauth = Invoke-RestMethod -Method Post -Uri $postString -Body $body
    $headerParams = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"}

    return $headerParams;
}



#Checks if the subscription exists
function checkOffice365Subscriptions 
{
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$resource,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$TenantGUID,
        [Parameter(Mandatory=$true, Position=2)]
        [hashtable]$headerParams
    )

        $getSubscriptionsString = -join($resource,"/api/v1.0/",$tenantGUID,"/activity/feed/subscriptions/list");
        $check_Subscription = Invoke-WebRequest -Headers $headerParams -Uri $getSubscriptionsString

        return $check_Subscription;
}


#start a subscription to a service such as Audit.General. 
function startOffice365Subscription
{
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$resource,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$TenantGUID,
        [Parameter(Mandatory=$true, Position=2)]
        [hashtable]$headerParams,
        [Parameter(Mandatory=$true, Position=3)]
        $subscription
    )

        $startSubscriptionString = -join($resource,"/api/v1.0/",$tenantGUID,"/activity/feed/subscriptions/start?contentType=",$subscription);
        Invoke-WebRequest -Method Post -Headers $headerParams -Uri $startSubscriptionString;
}


    #gets the unique code from the content blob for reading. 
function getOffice365ContentTypeFromSubscription
{   
     param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$resource,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$TenantGUID,
        [Parameter(Mandatory=$true, Position=2)]
        [hashtable]$headerParams,
        [Parameter(Mandatory=$true, Position=3)]
        $subscription
    )
        $contentString = -join($resource,"/api/v1.0/",$tenantGUID,"/activity/feed/subscriptions/content?contentType=",$subscription);
        $contentType = Invoke-WebRequest -Headers $headerParams -Uri $contentString;
        $contentType = $contentType.Content | ConvertFrom-Json;
        #Retreives the latest date of all the blobs 
        $blobDates = $contentType
        $sortBlobDate = $blobDates | Sort-Object {[DateTime]$_."contentCreated"}
        $contentType = $sortBlobDate |  Select-Object -Last 1;

        return $contentType;
}

#actually gets the content from the chosen blob. Takes in the chosen workload for filtering. 
function getOffice365LogsFromContent 
{
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$resource,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$TenantGUID,
        [Parameter(Mandatory=$true, Position=2)]
        [hashtable]$headerParams,
        [Parameter(Mandatory=$true, Position=3)]
        [string]$workload,
        [Parameter(Mandatory=$true, Position=4)]
        [object]$contentType
    )
        $contentString = -join($resource,"/api/v1.0/",$tenantGUID,"/activity/feed/audit/",$contentType.contentId);
        $logContent = Invoke-WebRequest -Headers $headerParams -Uri $contentString;

        #Convers the log output from json to object so it can be parsed easier.
        $logConvertFromJson = $logContent | ConvertFrom-Json;
        $logsFiltered = $logConvertFromJson | where-object -Property Workload -EQ $workload;

        return $logsFiltered;
}

Export-ModuleMember -Function '*'