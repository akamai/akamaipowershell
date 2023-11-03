function Rename-CPCode
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $CPCode,
        [Parameter(Mandatory=$true)]  [string] $NewName,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Code = Get-CPCode -CPCode $CPCode -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
    $Code.cpcodeName = $NewName
    $Body = $Code | ConvertTo-Json -Depth 100

    try {
        $Result = Set-CPCode -CPCode $CPCode -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        Write-Host "Error updating CP Code $CPCode"
        throw $_
    }
}
