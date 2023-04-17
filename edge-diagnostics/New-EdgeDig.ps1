function New-EdgeDig
{
    [CmdletBinding(DefaultParameterSetName = 'ip')]
    Param(
        [Parameter(Mandatory=$true)]  [string] $Hostname,
        [Parameter(Mandatory=$false)]  [string] [ValidateSet('A','AAAA','SOA','CNAME','PTR','MX','NS','TXT','SRV','CAA','ANY')] $QueryType = 'ANY',
        [Parameter(Mandatory=$false,ParameterSetName='ip')]  [string] $EdgeIP,
        [Parameter(Mandatory=$false,ParameterSetName='location')] [string] $EdgeLocation,
        [Parameter(Mandatory=$false)] [switch] $IsGTMHostname,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edge-diagnostics/v1/dig"

    $BodyObj = @{
        hostname = $Hostname
        queryType = $QueryType
        isGtmHostname = $IsGTMHostname.IsPresent
    }

    if($EdgeIP -ne ''){
        $BodyObj['edgeIp'] = $EdgeIP 
    }

    if($EdgeLocation -ne ''){
        $BodyObj['edgeLocation'] = $EdgeLocation 
    }

    $Body = ConvertTo-Json $BodyObj

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
