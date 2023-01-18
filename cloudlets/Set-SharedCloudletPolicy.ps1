function Set-SharedCloudletPolicy
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $Description,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/cloudlets/v3/policies/$PolicyID`?accountSwitchKey=$AccountSwitchKey"

    $BodyObj = @{
        groupId = $GroupID
    }

    if($Description){
        $BodyObj['description'] = $Description
    }

    $Body = ConvertTo-Json $BodyObj -Depth 100

    try {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_ 
    }
}
