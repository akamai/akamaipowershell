function List-CtrApiContracts
{
    Param(
        [Parameter(Mandatory=$false)] [string] [ValidateSet('TOP', 'ALL')] $Depth,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/contract-api/v1/contracts/identifiers?depth=$Depth"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }  
}
