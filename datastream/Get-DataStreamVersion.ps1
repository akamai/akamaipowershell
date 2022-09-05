function Get-DataStreamVersion
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $StreamID,
        [Parameter(Mandatory=$false)] [string] $Version,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/datastream-config-api/v1/log/streams/$StreamID`?version=$Version&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}

Set-Alias -Name Get-DS2StreamVersion -Value Get-DataStreamVersion