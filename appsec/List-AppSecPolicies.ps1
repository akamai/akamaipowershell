function List-AppSecPolicies
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ConfigID,
        [Parameter(Mandatory=$true)]  [int]    $VersionNumber,
        [Parameter(Mandatory=$false)] [switch] $NotMatched,
        [Parameter(Mandatory=$false)] [switch] $Detail,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $NotMatchedString = $NotMatched.IsPresent.ToString().ToLower()
    if(!$NotMatched){ $NotMatchedString = '' }
    $DetailString = $Detail.IsPresent.ToString().ToLower()
    if(!$Detail){ $DetailString = '' }

    $Path = "/appsec/v1/configs/$ConfigID/versions/$VersionNumber/security-policies?notMatched=$NotMatchedString&detail=$DetailString&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.policies
    }
    catch {
        throw $_.Exception 
    }
}