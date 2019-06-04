function List-AppSecConfigurationVersions
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ConfigID,
        [Parameter(Mandatory=$false)] [switch] $Detail,
        [Parameter(Mandatory=$false)] [int]    $Page = 1,
        [Parameter(Mandatory=$false)] [int]    $PageSize = 25,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $DetailString = $Detail.IsPresent.ToString().ToLower()
    if(!$Detail){ $DetailString = '' }

    $Path = "/appsec/v1/configs/$ConfigID/versions?detail=$DetailString&page=$Page&pagSize=$PageSize&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception 
    }
}