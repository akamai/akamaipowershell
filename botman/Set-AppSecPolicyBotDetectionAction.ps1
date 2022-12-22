function Set-AppSecPolicyBotDetectionAction
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $ConfigName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]    [string] $ConfigID,
        [Parameter(Mandatory=$true)]  [string] $VersionNumber,
        [Parameter(Mandatory=$false)] [string] $PolicyName,
        [Parameter(Mandatory=$false)] [string] $PolicyID,
        [Parameter(Mandatory=$true)]  [string] $DetectionID,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]  [string] $DetectionAction,
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
    
        if($VersionNumber.ToLower() -eq 'latest'){
            $VersionNumber = (List-AppSecConfigurationVersions -ConfigID $ConfigID -PageSize 1 -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey).version
        }
    
        if($PolicyName){
            $PolicyID = (List-AppsecPolicies -ConfigID $ConfigID -VersionNumber $VersionNumber -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey | where {$_.policyName -eq $PolicyName}).policyId
        }
    
        if($DetectionAction){
            $Body = ConvertTo-Json -depth 100 $DetectionAction
        }
    
        $Path = "/appsec/v1/configs/$ConfigID/versions/$VersionNumber/security-policies/$PolicyID/bot-detection-actions/$DetectionID`?accountSwitchKey=$AccountSwitchKey"
    
        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_
        }
    }

    end{}
}