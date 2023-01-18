function Get-DigFromGhostLocation
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $LocationID,
        [Parameter(Mandatory=$true)]  [string] $Hostname,
        [Parameter(Mandatory=$false)] [string] $QueryType,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/diagnostic-tools/v2/ghost-locations/$LocationID/dig-info?hostName=$Hostname&queryType=$QueryType&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}
