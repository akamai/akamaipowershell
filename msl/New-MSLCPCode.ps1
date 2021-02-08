function New-MSLCPCode
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Name,
        [Parameter(Mandatory=$true)]  [string] $ContractID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/config-media-live/v2/msl-origin/cpcodes?accountSwitchKey=$AccountSwitchKey"

    $BodyObj = @{
        name = $Name
        contractId = $ContractID
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