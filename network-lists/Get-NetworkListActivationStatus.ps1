function Get-NetworkListActivationStatus
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $NetworkListID,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('PRODUCTION','STAGING')] $Environment = 'PRODUCTION',
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/network-list/v2/network-lists/$NetworkListId/environments/$Environment/status"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
