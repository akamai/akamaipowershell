function Generate-Report
{
    Param(
        [Parameter(Mandatory=$true)] [String] $ReportType,
        [Parameter(Mandatory=$true)] [String] $Version,
        [Parameter(Mandatory=$true)] [String] $Start,
        [Parameter(Mandatory=$true)] [String] $End,
        [Parameter(Mandatory=$true)] [ValidateSet('FIVE_MINUTES','HOUR', 'DAY', 'WEEK', 'MONTH')] [String] $Interval,
        [Parameter(Mandatory=$false, ParameterSetName='attributes')] [string] $CPCodes,
        [Parameter(Mandatory=$false, ParameterSetName='attributes')] [string] $Metrics,
        [Parameter(Mandatory=$false, ParameterSetName='postbody')] [String] $Body,
        [Parameter(Mandatory=$false)] [string] $Limit,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey,
        [Parameter(Mandatory=$false, ParameterSetName='attributes')] [ValidateSet('secure','non_secure')] [string] $DeliveryType,
        [Parameter(Mandatory=$false, ParameterSetName='attributes')] [ValidateSet('ipv4','ipv6')] [string] $IPVersion,
        [Parameter(Mandatory=$false, ParameterSetName='attributes')] [switch] $CacheableOnly,
        [Parameter(Mandatory=$false, ParameterSetName='attributes')] [switch] $NonCacheableOnly,
        [Parameter(Mandatory=$false, ParameterSetName='attributes')] [ValidateSet('get_head_responses','put_post_requests','all_responses','put_post_responses')] [string] $Traffic
    )

    $DateTimeMatch = '[\d]{4}-[\d]{2}-[\d]{2}T[\d]{2}:[\d]{2}:[\d]{2}Z'
    if($Start -notmatch $DateTimeMatch -or $End -notmatch $DateTimeMatch){
        throw "ERROR: Start & End must be in the format 'YYYY-MM-DDThh:mm:ssZ'"
    }

    $Params = "start=$Start&end=$End&interval=$Interval&limit=$Limit&accountSwitchKey=$AccountSwitchKey"
    $EncodedParams = [System.Web.HttpUtility]::UrlEncode($Params)
    $EncodedParams = $EncodedParams.Replace("%3d","=") #Easier to read
    $EncodedParams = $EncodedParams.Replace("%26","&")

    $Path = "/reporting-api/v1/reports/$ReportType/versions/$Version/report-data?$EncodedParams"

    if($PSCmdlet.ParameterSetName -eq 'attributes'){
        $BodyObj = @{ 
            objectType = 'cpcode'
            filters = @{}
        }
        
        # Cp Codes / ObjectIds
        if($CPCodes.Contains(",")){
            $CPCodeArray = $CPCodes.Split(",")
            $ObjectIDs = $CPCodeArray
        }
        elseif($CPCodes -eq 'all'){
            $ObjectIDs = 'all'
        }
        else{
            $CPCodeArray = @()
            $CPCodeArray += $CPCodes
            $ObjectIDs = $CPCodeArray
        }
        $BodyObj['objectIds'] = $ObjectIDs

        # Metrics
        if($Metrics){
            $MetricsArray = $Metrics -split ","
            $BodyObj['metrics'] = $MetricsArray
        }

        # Filters
        if($DeliveryType){
            $BodyObj['filters']['delivery_type'] = @($DeliveryType)
        }
        if($IPVersion){
            $BodyObj['filters']['ip_version'] = @($IPVersion)
        }
        if($CacheableOnly){
            $BodyObj['filters']['ca'] = @('cacheable')
        }
        elseif($NonCacheableOnly){
            $BodyObj['filters']['ca'] = @('non_cacheable')
        }
        if($Traffic){
            $BodyObj['filters']['traffic'] = @($Traffic)
        }

        $Body = $BodyObj | ConvertTo-Json -Depth 100
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $Body
        return $Result
    }
    catch {
        throw $_.Exception
    }
}