function New-CloudletLoadBalancingVersion
{
    [CmdletBinding(DefaultParameterSetName = 'pipeline')]
    Param(
        [Parameter(Mandatory=$true)]  [string] $OriginID,
        [Parameter(Mandatory=$true,ParameterSetName="pipeline",ValueFromPipeline=$true)]  [object] $LoadBalancer,
        [Parameter(Mandatory=$true,ParameterSetName="postbody")]  [string] $Body,
        [Parameter(Mandatory=$false)] [switch] $Validate,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin {}

    process{
        # nullify false switches
        $ValidateString = $Validate.IsPresent.ToString().ToLower()
        if(!$Validate){ $ValidateString = '' }
        
        $Path = "/cloudlets/api/v2/origins/$OriginID/versions?validate=$ValidateString&accountSwitchKey=$AccountSwitchKey"

        $AdditionalHeaders = @{
            'Content-Type' = 'application/json'
        }

        if($LoadBalancer){
            $Body = ConvertTo-Json $LoadBalancer -Depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_
        }
    }

    end{}
}