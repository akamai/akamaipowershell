function New-EdgeWorker
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Name,
        [Parameter(Mandatory=$true)]  [int]    $GroupID,
        [Parameter(Mandatory=$true)]  [int] [ValidateSet(100,200)] $ResourceTierID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edgeworkers/v1/ids?accountSwitchKey=$AccountSwitchKey"

    $BodyObj = @{
        name = $Name
        groupId = $GroupID
        resourceTierId = $ResourceTierID
    }
    $Body = $BodyObj | ConvertTo-Json

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}
