function Set-EdgeHostname
{
    Param(
        [Parameter(Mandatory=$true)] [string] $RecordName,
        [Parameter(Mandatory=$true)] [string] $DNSZone,
        [Parameter(Mandatory=$true, ParameterSetName='attributes')] [string] [ValidateSet('ttl','ipVersionBehavior')] $Path,
        [Parameter(Mandatory=$true, ParameterSetName='attributes')] [string] $Value,
        [Parameter(Mandatory=$true, ParameterSetName='postbody')] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $Comments,
        [Parameter(Mandatory=$false)] [string] $StatusUpdateEmail,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $ReqPath = "/hapi/v1/dns-zones/$DNSZone/edge-hostnames/$RecordName`?comments=$Comments&statusUpdateEmail=$StatusUpdateEmail"
    $AdditionalHeaders = @{
        'Content-Type' = 'application/json-patch+json'
    }

    if($PSCmdlet.ParameterSetName -eq 'attributes'){
        $Body = "[{`"op`": `"replace`",`"path`": `"/$Path`",`"value`": `"$Value`"}]"
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method PATCH -Path $ReqPath -Body $Body -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
