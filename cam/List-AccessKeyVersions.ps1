function List-AccessKeyVersions
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $AccessKeyUID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/cam/v1/access-keys/$AccessKeyUID/versions?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.accessKeyVersions
    }
    catch {
        throw $_.Exception
    }
}