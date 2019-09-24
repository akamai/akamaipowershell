Function Set-PropertyRuleTree
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/properties/$PropertyId/versions/$PropertyVersion/rules?contractId=$ContractId&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"

    try
    {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $Body
        return $Result
    }
    catch
    {
        throw $_.Exception
    }
}