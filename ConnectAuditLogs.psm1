Class OnlineManagementApi { 

    #Initialise the client variables for connecting to the API and getting the token.
    [string]$ClientID
    [string]$ClientSecret
    [string]$loginURL
    [string]$tenantdomain
    [string]$TenantGUID
    [string]$resource
    [string]$check_Subscription;
    [hashtable]$headerParams; 
    [object]$contentType;
    [object]$logsFiltered;

    #Gets the token to connect to the online management api. 
    [void]getToken() {
        $body = @{grant_type="client_credentials";resource=$this.resource;client_id=$this.ClientID;client_secret=$this.ClientSecret}
        $postString = -join($this.loginURL,"/",$this.tenantdomain,"/oauth2/token?api-version=1.0");
        $oauth = Invoke-RestMethod -Method Post -Uri $postString -Body $body
        $this.headerParams = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"}
    }

    #Checks if the subscription exists
    [void]checkSubscriptions() {
        $getSubscriptionsString = -join($this.resource,"/api/v1.0/",$this.tenantGUID,"/activity/feed/subscriptions/list");
        $this.check_Subscription = Invoke-WebRequest -Headers $this.headerParams -Uri $getSubscriptionsString
    }

    #start a subscription to a service such as Audit.General. 
    [void]startSubscription([string]$subscription) {
        $startSubscriptionString = -join($this.resource,"/api/v1.0/",$this.tenantGUID,"/activity/feed/subscriptions/start?contentType=",$subscription);
        Invoke-WebRequest -Method Post -Headers $this.headerParams -Uri $startSubscriptionString;
    }

    #gets the unique code from the content blob for reading. 
    [void]getContentTypeFromSubscription([string]$subscription) {
        $contentString = -join($this.resource,"/api/v1.0/",$this.tenantGUID,"/activity/feed/subscriptions/content?contentType=",$subscription);
        $this.contentType = Invoke-WebRequest -Headers $this.headerParams -Uri $contentString;
        $this.contentType = $this.contentType.Content | ConvertFrom-Json;
        #Retreives the latest date of all the blobs 
        $blobDates = $this.contentType
        $sortBlobDate = $blobDates | Sort-Object {[DateTime]$_."contentCreated"}
        $this.contentType = $sortBlobDate |  Select-Object -Last 1;
    }

    #actually gets the content from the chosen blob. Takes in the chosen workload for filtering. 
    [void]getLogsFromContent([string]$workload) {
        $contentString = -join($this.resource,"/api/v1.0/",$this.tenantGUID,"/activity/feed/audit/",$this.contentType.contentId);
        $logContent = Invoke-WebRequest -Headers $this.headerParams -Uri $contentString;
        #Convers the log output from json to object so it can be parsed easier.
        $logConvertFromJson = $logContent | ConvertFrom-Json;
        $this.logsFiltered = $logConvertFromJson | where-object -Property Workload -EQ $workload;
    }
}