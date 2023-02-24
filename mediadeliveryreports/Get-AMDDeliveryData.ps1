function Get-AMDDeliveryData
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $DataStoreID,
        [Parameter(Mandatory=$true)]  [string] $StartDate,
        [Parameter(Mandatory=$true)]  [string] $EndDate,
        [Parameter(Mandatory=$true)]  [string] $Dimensions,
        [Parameter(Mandatory=$true)]  [string] $Metrics,
        [Parameter(Mandatory=$false)] [string] $Aggregation,
        [Parameter(Mandatory=$false)] [string] $CPCodes,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('sps_hds', 'sp_hls', 'pr_hls', 'pt_hds', 'pt_dash', 'smooth', 'others', 'all')] $DeliveryFormat,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('non-secure', 'secure-shared', 'secure-standard', 'secure-premium', 'all', 'http', 'ssl', 'essl')] $DeliveryOption,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('all', 'live', 'vod')] $DeliveryType,
        [Parameter(Mandatory=$false)] [string] $FilterParams,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('all', 'ipv4', 'ipv6')] $IPVersion,
        [Parameter(Mandatory=$false)] [int]    $Limit,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('all', 'accelerated', 'nonaccelerated')] $MediaAcceleration,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('all', 'encrypted', 'unencrypted')] $MediaEncryption,
        [Parameter(Mandatory=$false)] [int]    $Offset,
        [Parameter(Mandatory=$false)] [switch] $Reduce,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $DateTimeNoSecondsMatch = '[\d]{4}-[\d]{2}-[\d]{2}T[\d]{2}:[\d]{2}Z'
    if($StartDate -notmatch $DateTimeNoSecondsMatch -or $EndDate -notmatch $DateTimeNoSecondsMatch){
        throw "ERROR: Start & End must be in the format 'YYYY-MM-DDThh:mmZ'"
    }

    # nullify false switches
    $ReduceString = $Reduce.IsPresent.ToString().ToLower()
    if(!$Reduce){ $ReduceString = '' }

    $Path = "/media-delivery-reports/v1/adaptive-media-delivery/realtime-data?startDate=$StartDate&endDate=$EndDate&dimensions=$Dimensions&metrics=$Metrics&aggregation=$Aggregation&limit=$Limit&offset=$Offset&reduce=$ReduceString"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey -Body $Body
        return $Result
    }
    catch {
        throw $_
    }
}
