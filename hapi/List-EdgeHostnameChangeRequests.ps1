function List-EdgeHostnameChangeRequests
{
    Param(
        [Parameter(Mandatory=$false)] [string] [ValidateSet('PENDING')] $Status,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/hapi/v1/change-requests?status=$Status"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey -Body $Body
        return $Result.changeRequests
    }
    catch {
        throw $_
    }
}
