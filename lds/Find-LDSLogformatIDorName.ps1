function Find-LDSLogformatIDOrName
{
    Param(
        [Parameter(Mandatory=$false)] [int]    $LogFormatID,
        [Parameter(Mandatory=$false)] [string] $LogFormatName,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $LogFormats = List-LDSLogFormatsByType -Section $Section -AccountSwitchKey $AccountSwitchKey

    if($LogFormatID)
    {
        $Format = $LogFormats | where {$_.id -eq $LogFormatID}
        return $Format.value
    }

    elseif($LogFormatName)
    {
        Write-host "Name"
        $Format = $LogFormats | where {$_.value -eq $LogFormatName}
        return $Format.id
    }
}