function Set-ChinaCDNDeprovisionPolicy
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $EdgeHostname,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)]  [object] $DeprovisionPolicy,
        [Parameter(Mandatory=$true,ParameterSetName='body')] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/chinacdn/v1/edge-hostnames/$EdgeHostname/deprovision-policy"

        $AdditionalHeaders = @{
            Accept = 'application/vnd.akamai.chinacdn.deprovision-policy.v1+json'
        }

        if($DeprovisionPolicy){
            $Body = ConvertTo-Json -Depth 100 $DeprovisionPolicy
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            return $Result
        }
        catch {
            throw $_ 
        }
    }

    end{}
}
