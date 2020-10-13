function Set-AppSecPolicyMode
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $ConfigName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]    [string] $ConfigID,
        [Parameter(Mandatory=$true)]  [string] $VersionNumber,
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('KRS','AAG')] $Mode,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

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

    $Path = "/appsec/v1/configs/$ConfigID/versions/$VersionNumber/security-policies/$PolicyID/mode?accountSwitchKey=$AccountSwitchKey"

    $BodyObj = @{
        mode = $Mode
    }
    $Body = $BodyObj | ConvertTo-Json

    try {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception 
    }
}