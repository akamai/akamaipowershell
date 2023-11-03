function Set-CloudletLoadBalancingVersion
{
    [CmdletBinding(DefaultParameterSetName = 'pipeline')]
    Param(
        [Parameter(Mandatory=$true)]  [string] $OriginID,
        [Parameter(Mandatory=$true)]  [string] $Version,
        [Parameter(Mandatory=$true,ParameterSetName="pipeline",ValueFromPipeline=$true)]  [object] $LoadBalancer,
        [Parameter(Mandatory=$true,ParameterSetName="postbody")]  [string] $Body,
        [Parameter(Mandatory=$false)] [switch] $Validate,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin {}

    process{
        # nullify false switches
        $ValidateString = $Validate.IsPresent.ToString().ToLower()
        if(!$Validate){ $ValidateString = '' }

        if($Version -eq 'latest'){
            $Versions = List-CloudletLoadBalancingVersions -OriginID $OriginID -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            $Versions = $Versions | Sort-Object -Property Version -Descending
            $Version = $Versions[0].version
        }
        
        $Path = "/cloudlets/api/v2/origins/$OriginID/versions/$Version`?validate=$ValidateString"

        $AdditionalHeaders = @{
            'Content-Type' = 'application/json'
        }

        if($LoadBalancer){
            $Body = ConvertTo-Json $LoadBalancer -Depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            return $Result
        }
        catch {
            throw $_
        }
    }

    end{}
}
