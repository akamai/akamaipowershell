function New-AppSecCustomRule
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $ConfigName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]    [string] $ConfigID,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)] [object] $CustomRule,
        [Parameter(Mandatory=$false)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        if($ConfigName){
            $Config = List-AppSecConfigurations -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey | where {$_.name -eq $ConfigName}
            if($Config){
                $ConfigID = $Config.id
            }
            else{
                throw("Security config '$ConfigName' not found")
            }
        }
    
        $Path = "/appsec/v1/configs/$ConfigID/custom-rules?accountSwitchKey=$AccountSwitchKey"
    
        if($CustomRule){
            $Body = $CustomRule | ConvertTo-Json -Depth 100
        }
    
        try {
            $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $Body
            return $Result
        }
        catch {
            throw $_ 
        }
    }

    end{}
}
