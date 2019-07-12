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
        [Parameter(Mandatory=$false)] [string] $Limit,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $DateTimeMatch = '[\d]{4}-[\d]{2}-[\d]{2}T[\d]{2}:[\d]{2}:[\d]{2}Z'
    if($Start -notmatch $DateTimeMatch -or $End -notmatch $DateTimeMatch){
        throw "ERROR: Start & End must be in the format 'YYYY-MM-DDThh:mm:ssZ'"
    }

    # Nullify false switches
    $AllObjectIdsString = $AllObjectIds.IsPresent.ToString().ToLower()
    if(!$AllObjectIds){ $AllObjectIdsString = '' }

    $Params = "start=$Start&end=$End&interval=$Interval&objectType=$ObjectType&allObjectIds=$AllObjectIdsString&filters=$Filters&metrics=$Metrics&objectIds=$ObjectIds&limit=$Limit&accountSwitchKey=$AccountSwitchKey"
    $EncodedParams = [System.Web.HttpUtility]::UrlEncode($Params)
    $EncodedParams = $EncodedParams.Replace("%3d","=") #Easier to read
    $EncodedParams = $EncodedParams.Replace("%26","&")
    $Path = "/reporting-api/v1/reports/$ReportType/versions/$Version/report-data?$EncodedParams"
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}