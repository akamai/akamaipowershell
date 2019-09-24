function Get-GTMDomain
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $DomainName,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/config-gtm/v1/domains/$DomainName`?accountSwitchKey=$AccountSwitchKey"
    $AdditionalHeaders = @{ 'Accept' = 'application/vnd.config-gtm.v1.1+json'}

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AdditionalHeaders $AdditionalHeaders
        return $Result
    }
    catch {
        throw $_.Exception
    }  
}