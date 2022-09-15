function Set-ChinaCDNDeprovisionPolicy
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $EdgeHostname,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)]  [string] $DeprovisionPolicy,
        [Parameter(Mandatory=$true,ParameterSetName='body')] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/chinacdn/v1/edge-hostnames/$EdgeHostname/deprovision-policy?accountSwitchKey=$AccountSwitchKey"

        $AdditionalHeaders = @{
            Accept = 'application/vnd.akamai.chinacdn.deprovision-policy.v1+json'
        }

        if($DeprovisionPolicy){
            $Body = $DeprovisionPolicy | ConvertTo-Json -Depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_ 
        }
    }

    end{}
}
