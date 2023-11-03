function Get-GTMDomain
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $DomainName,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/config-gtm/v1/domains/$DomainName"
    $AdditionalHeaders = @{ 'Accept' = 'application/vnd.config-gtm.v1.1+json'}

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey -AdditionalHeaders $AdditionalHeaders
        return $Result
    }
    catch {
        throw $_
    }  
}
