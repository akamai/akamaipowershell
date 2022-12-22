function Get-DiagnosticLink
{
    [CmdletBinding(DefaultParameterSetName = 'url')]
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='url')]  [string] $URL,
        [Parameter(Mandatory=$true,ParameterSetName='ipa')]  [string] $IPAHostname,
        [Parameter(Mandatory=$false)] [string] $Note,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edge-diagnostics/v1/user-diagnostic-data/groups?accountSwitchKey=$AccountSwitchKey"

    $BodyObj = @{}
    if($URL -ne ''){
        $BodyObj['url'] = $URL
    }
    if($IPAHostname -ne ''){
        $BodyObj['ipaHostname'] = $IPAHostname
    }
    if($Note -ne ''){
        $BodyObj['note'] = $Note
    }
    $Body = ConvertTo-Json $BodyObj

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}