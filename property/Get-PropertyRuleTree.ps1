function Get-PropertyRuleTree
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $PropertyName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $RuleFormat,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($PropertyName){
        $PropertyID = (Find-Property -PropertyName $PropertyName -latest -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey).propertyId
        if($PropertyID -eq ''){
            throw "Property '$PropertyName' not found"
        }
    }

    $Path = "/papi/v1/properties/$PropertyId/versions/$PropertyVersion/rules?contractId=$ContractId&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"

    if($RuleFormat){
        $AdditionalHeaders = @{
            Accept = "application/vnd.akamai.papirules.$RuleFormat+json"
        }
    }

    try {
        $PropertyRuleTree = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $PropertyRuleTree
    }
    catch {
        throw $_.Exception
    }
}