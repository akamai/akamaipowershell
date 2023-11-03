function Get-AMDRealTimeData
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $DataStoreID,
        [Parameter(Mandatory=$true)]  [string] $StartDate,
        [Parameter(Mandatory=$true)]  [string] $EndDate,
        [Parameter(Mandatory=$true)]  [string] $Dimensions,
        [Parameter(Mandatory=$true)]  [string] $Metrics,
        [Parameter(Mandatory=$false)] [int]    [ValidateSet(300, 3600, 86400)] $Aggregation,
        [Parameter(Mandatory=$false)] [int]    $Limit,
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
