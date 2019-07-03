function List-AppSecMatchTargets
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ConfigID,
        [Parameter(Mandatory=$true)]  [int]    $VersionNumber,
        [Parameter(Mandatory=$false)] [string] $PolicyID,
        [Parameter(Mandatory=$false)] [switch] $IncludeChildObjectName,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $IncludeChildObjectNameString = $IncludeChildObjectName.IsPresent.ToString().ToLower()
    if(!$IncludeChildObjectName){ $IncludeChildObjectNameString = '' }

    $Path = "/appsec/v1/configs/$ConfigID/versions/$VersionNumber/match-targets?policyId=$PolicyID&includeChildObjectName=$IncludeChildObjectNameString&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.matchTargets
    }
    catch {
        throw $_.Exception 
    }
}