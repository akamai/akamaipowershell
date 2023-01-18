function List-EdgeHostnameChangeRequests
{
    Param(
        [Parameter(Mandatory=$false)] [string] [ValidateSet('PENDING')] $Status,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/hapi/v1/change-requests?status=$Status&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $Body
        return $Result.changeRequests
    }
    catch {
        throw $_
    }
}
