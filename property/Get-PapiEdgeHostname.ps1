function Get-PapiEdgeHostname
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $EdgeHostnameID,
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $Options,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/edgehostnames/$EdgeHostnameID`?contractId=$ContractId&groupId=$GroupID&options=$Options"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.edgehostnames.items
    }
    catch {
        throw $_
    }
}
