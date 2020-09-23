function Set-AppSecRatePolicy
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $ConfigName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]    [string] $ConfigID,
        [Parameter(Mandatory=$true)]  [int]    $VersionNumber,
        [Parameter(Mandatory=$true)]  [int]    $RatePolicyID,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]  [object] $RatePolicy,
        [Parameter(Mandatory=$false)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        if($ConfigName){
            $Config = List-AppSecConfigurations -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey | where {$_.name -eq $ConfigName}
            $ConfigID = $Config.id
        }
    
        if($RatePolicy){
            $Body = $RatePolicy | ConvertTo-Json -Depth 100
        }
    
        $Path = "/appsec/v1/configs/$ConfigID/versions/$VersionNumber/rate-policies/$RatePolicyID`?accountSwitchKey=$AccountSwitchKey"
    
        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_.Exception 
        }
    }

    end{}
}