function Set-GTMDomainResource
{
    [alias('New-GTMDomainResource')]
    Param(
        [Parameter(Mandatory=$true)] [string] $DomainName,
        [Parameter(Mandatory=$true)] [string] $ResourceName,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName='pipeline')] [object] $Resource,
        [Parameter(Mandatory=$true,ParameterSetName='postbody')] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/config-gtm/v1/domains/$DomainName/resources/$ResourceName"

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
