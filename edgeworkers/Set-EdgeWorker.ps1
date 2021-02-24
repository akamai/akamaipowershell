function Set-EdgeWorker
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $EdgeWorkerID,
        [Parameter(Mandatory=$true)]  [string] $Name,
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edgeworkers/v1/ids/$EdgeWorkerID`?accountSwitchKey=$AccountSwitchKey"

    $BodyObj = @{
        name = $Name
        groupId = $GroupID
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