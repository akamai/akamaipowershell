function Activate-AppSecConfiguration
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $ConfigName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]    [string] $ConfigID,
        [Parameter(Mandatory=$true)]  [int]    [Alias('Version')] $VersionNumber,
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('STAGING','PRODUCTION')] $Network,
        [Parameter(Mandatory=$true)]  [string] $NotificationEmails,
        [Parameter(Mandatory=$true)]  [string] $Note,
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

    $Path = "/appsec/v1/configs/$ConfigID/activations?accountSwitchKey=$AccountSwitchKey"

    $BodyObj = @{
        action = 'ACTIVATE'
        network = $Network
        activationConfigs = @(
            @{
                configId = $ConfigID
                configVersion = $Version
            }
        )
        note = $Note
    }

    if($NotificationEmails.Contains(",")){
        $BodyObj['notificationEmails'] = $NotificationEmails -split ","
    }
    else{
        $BodyObj['notificationEmails'] = @($NotificationEmails)
    }

    $Body = $BodyObj | ConvertTo-Json -Depth 100

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_ 
    }
}
