function Activate-AppSecConfiguration {
    Param(
        [Parameter(ParameterSetName = "name", Mandatory = $true)]  [string] $ConfigName,
        [Parameter(ParameterSetName = "id", Mandatory = $true)]    [int] $ConfigID,
        [Parameter(Mandatory = $true)]  [string] [Alias('Version')] $VersionNumber,
        [Parameter(Mandatory = $true)]  [string] [ValidateSet('STAGING', 'PRODUCTION')] $Network,
        [Parameter(Mandatory = $true)]  [string] $NotificationEmails,
        [Parameter(Mandatory = $false)] [string] $Note,
        [Parameter(Mandatory = $false)] [string] $EdgeRCFile,
        [Parameter(Mandatory = $false)] [string] $Section,
        [Parameter(Mandatory = $false)] [string] $AccountSwitchKey
    )

    if ($ConfigName) {
        $Config = List-AppSecConfigurations -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey | Where-Object { $_.name -eq $ConfigName }
        if ($Config) {
            $ConfigID = $Config.id
        }
        else {
            throw("Security config '$ConfigName' not found")
        }
    }

    if ($VersionNumber.ToLower() -eq 'latest') {
        $Version = (List-AppSecConfigurationVersions -ConfigID $ConfigID -PageSize 1 -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey).version
    }
    else {
        $Version = [int] $VersionNumber
    }

    $Path = "/appsec/v1/activations"

    $BodyObj = @{
        action             = 'ACTIVATE'
        network            = $Network
        activationConfigs  = @(
            @{
                configId      = $ConfigID
                configVersion = $Version
            }
        )
        note               = $Note
        notificationEmails = ($NotificationEmails -split ',')
    }

    $Body = ConvertTo-Json $BodyObj -Depth 10

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_ 
    }
}