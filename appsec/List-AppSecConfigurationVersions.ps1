function List-AppSecConfigurationVersions
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $ConfigName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]    [string] $ConfigID,
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

    if($ConfigName){
        $Config = List-AppSecConfigurations -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey | where {$_.name -eq $ConfigName}
        if($Config){
            $ConfigID = $Config.id
        }
        else{
            throw("Security config '$ConfigName' not found")
        }
    }

    $Path = "/appsec/v1/configs/$ConfigID/versions?detail=$DetailString&page=$Page&pageSize=$PageSize&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.versionList
    }
    catch {
        throw $_.Exception 
    }
}