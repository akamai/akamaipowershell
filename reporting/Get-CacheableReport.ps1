function Get-CacheableReport
{
    Param(
        [Parameter(Mandatory=$true)] [String] $ReportType,
        [Parameter(Mandatory=$true)] [String] $Version,
        [Parameter(Mandatory=$true)] [String] $Start,
        [Parameter(Mandatory=$true)] [String] $End,
        [Parameter(Mandatory=$true)] [ValidateSet("FIVE_MINUTES","HOUR", "DAY", "WEEK", "MONTH")] [String] $Interval,
        [Parameter(Mandatory=$true)] [ValidateSet("cpcode")] [String] $ObjectType,
        [Parameter(Mandatory=$false)] [Switch] $AllObjectIds,
        [Parameter(Mandatory=$false)] [String] $Filters,
        [Parameter(Mandatory=$false)] [String] $Metrics,
        [Parameter(Mandatory=$false)] [String] $ObjectIds,
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $Params = "start=$Start&end=$End&interval=$Interval&objectType=$ObjectType&allObjectIds=$AllObjectIds&filters=$Filters&metrics=$Metrics&objectIds=$ObjectIds&accountSwitchKey=$AccountSwitchKey"
    $EncodedParams = [System.Web.HttpUtility]::UrlEncode($Params)
    $EncodedParams = $EncodedParams.Replace("%3d","=") #Easier to read
    $EncodedParams = $EncodedParams.Replace("%26","&")
    $ReqURL = "https://" + $Credentials.host + "/reporting-api/v1/reports/$ReportType/versions/$Version/report-data?$EncodedParams"
    
    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        return $Result
    }
    catch {
        throw $_.Exception
    }
}