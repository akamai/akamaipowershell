function Get-CacheableReport
{
    Param(
        [Parameter(Mandatory=$true)] [String] $ReportType,
        [Parameter(Mandatory=$true)] [String] $Version,
        [Parameter(Mandatory=$true)] [String] $Start,
        [Parameter(Mandatory=$true)] [String] $End,
        [Parameter(Mandatory=$false,ParameterSetName='ids')] [String] $ObjectIDs,
        [Parameter(Mandatory=$false,ParameterSetName='all')] [Switch] $AllObjectIDs,
        [Parameter(Mandatory=$true)] [ValidateSet("FIVE_MINUTES","HOUR", "DAY", "WEEK", "MONTH")] [String] $Interval,
        [Parameter(Mandatory=$false)] [String] $Filters,
        [Parameter(Mandatory=$false)] [String] $Metrics,
        [Parameter(Mandatory=$false)] [string] $Limit,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $ISO8601Match = '[\d]{4}-[\d]{2}-[\d]{2}(T[\d]{2}:[\d]{2}(:[\d]{2})?(Z|[+-]{1}[\d]{2}[:][\d]{2})?)?'
    if($Start -notmatch $ISO8601Match -or $End -notmatch $ISO8601Match){
        throw "ERROR: Start & End must be in the format 'YYYY-MM-DDThh:mm(:ss optional) and (optionally) end with: 'Z' for UTC or '+/-XX:XX' to specify another timezone"
    }

    # Nullify false switches
    $AllObjectIDsString = $AllObjectIDs.IsPresent.ToString().ToLower()
    if(!$AllObjectIDs){ $AllObjectIDsString = '' }

    $Params = "start=$Start&end=$End&interval=$Interval&allObjectIds=$AllObjectIDsString&filters=$Filters&metrics=$Metrics&objectIds=$ObjectIds&limit=$Limit&accountSwitchKey=$AccountSwitchKey"
    $EncodedParams = [System.Web.HttpUtility]::UrlEncode($Params)
    $EncodedParams = $EncodedParams.Replace("%3d","=") #Easier to read
    $EncodedParams = $EncodedParams.Replace("%26","&")
    $Path = "/reporting-api/v1/reports/$ReportType/versions/$Version/report-data?$EncodedParams"
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}