function Remove-SharedCloudletPolicyVersion
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$true)]  [string] $Version,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($Version -eq 'latest'){
        $Version = (List-SharedCloudletPolicyVersions -PolicyID $PolicyID -Pagesize 10 -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey)[0].Version
    }

    $Path = "/cloudlets/v3/policies/$PolicyID/versions/$Version`?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method DELETE -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}