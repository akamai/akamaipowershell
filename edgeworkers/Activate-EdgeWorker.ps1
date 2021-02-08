function Activate-EdgeWorker
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $EdgeWorkerID,
        [Parameter(Mandatory=$true)]  [string] $Version,
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('STAGING','PRODUCTION')] $Network,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edgeworkers/v1/ids/$EdgeWorkerID/activations?accountSwitchKey=$AccountSwitchKey"

    $BodyObj = @{
        network = $Network
        version = $Version
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