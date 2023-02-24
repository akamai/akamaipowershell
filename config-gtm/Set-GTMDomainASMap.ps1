function Set-GTMDomainASMap
{
    [alias('New-GTMDomainASMap')]
    Param(
        [Parameter(Mandatory=$true)] [string] $DomainName,
        [Parameter(Mandatory=$true)] [string] $MapName,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)] [object] $ASMap,
        [Parameter(Mandatory=$true,ParameterSetName='postbody')] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/config-gtm/v1/domains/$DomainName/as-maps/$MapName"

        if($ASMap){
            $Body = $ASMap | ConvertTo-Json -Depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            return $Result
        }
        catch {
            throw $_
        }
    }

    end{}  
}
