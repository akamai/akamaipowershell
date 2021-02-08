function Validate-EdgeWorkerCodeBundle
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $CodeBundle,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if(!(Test-Path $CodeBundle)){
        throw "Code Bundle $CodeBundle could not be found"
    }

    $Path = "/edgeworkers/v1/validations?accountSwitchKey=$AccountSwitchKey"
    $AdditionalHeaders = @{
        'Content-Type' = 'application/gzip'
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -InputFile $CodeBundle -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}