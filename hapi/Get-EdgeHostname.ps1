function Get-EdgeHostname
{
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='id')]   [string] $EdgeHostnameID,
        [Parameter(Mandatory=$true,ParameterSetName='name')] [string] $EdgeHostname,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($PSCmdlet.ParameterSetName -eq 'id'){
        $Path = "/hapi/v1/edge-hostnames/$EdgeHostnameID`?accountSwitchKey=$AccountSwitchKey"
    }
    elseif($PSCmdlet.ParameterSetName -eq 'name'){
        if($EdgeHostname.Contains('.edgekey.net')){
            $DNSZone = 'edgekey.net'
            $RecordName = $EdgeHostname.Replace('.edgekey.net','')
        }
        elseif($EdgeHostname.Contains('.edgesuite.net')){
            $DNSZone = 'edgesuite.net'
            $RecordName = $EdgeHostname.Replace('.edgesuite.net','')
        }
        elseif($EdgeHostname.Contains('.akamaized.net')){
            $DNSZone = 'akamaized.net'
            $RecordName = $EdgeHostname.Replace('.akamaized.net','')
        }
        else{
            throw '$EdgeHostname must be in the format <recordName>.edge(suite|key).net or <recordName>.akamaized.net'
        }
    
        $Path = "/hapi/v1/dns-zones/$DNSZone/edge-hostnames/$RecordName`?accountSwitchKey=$AccountSwitchKey"
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}


