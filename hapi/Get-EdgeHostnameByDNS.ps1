function Get-EdgeHostnameByDNS
{
    Param(
        [Parameter(Mandatory=$true, ParameterSetName="fqdn")] [string] $FQDN,
        [Parameter(Mandatory=$true, ParameterSetName="components")] [string] $RecordName,
        [Parameter(Mandatory=$true, ParameterSetName="components")] [string] $DNSZone,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($PSCmdlet.ParameterSetName -eq 'fqdn'){
        $tld = $fqdn.Substring($fqdn.LastIndexOf("."))
        $notldfqdn = $fqdn.Substring(0,$fqdn.LastIndexOf("."))
        $RecordName = $notldfqdn.Substring(0,$notldfqdn.LastIndexOf("."))
        $DNSZone = $fqdn.Replace("$RecordName.","")
    }

    $Path = "/hapi/v1/dns-zones/$DNSZone/edge-hostnames/$RecordName`?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}

