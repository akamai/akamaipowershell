function New-TestConfigVersion
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ArlFileId,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/test-management/v2/functional/config-versions?accountSwitchKey=$AccountSwitchKey"

    $BodyObj = @{
        arlFileId = $ArlFileId
        propertyVersion = $PropertyVersion
    }

    $Body = $BodyObj | ConvertTo-Json

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception 
    }
}