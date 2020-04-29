function Get-NetworkListActivationStatus
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $NetworkListID,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('PRODUCTION','STAGING')] $Environment = 'PRODUCTION',
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/network-list/v2/network-lists/$NetworkListId/environments/$Environment/status?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}

