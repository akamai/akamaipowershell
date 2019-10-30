function Export-PropertyRuleTree
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $PropertyName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(Mandatory=$false)]  [string] $OutputFolder = ".",
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $RuleFormat,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    try {
        if($PropertyName){
            $PropertyRuleTree = Get-PropertyRuleTree -PropertyName $PropertyName -PropertyVersion $PropertyVersion -GroupID $GroupID -ContractId $ContractId -RuleFormat $RuleFormat -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        }
        else {
            $PropertyRuleTree = Get-PropertyRuleTree -PropertyId $PropertyId -PropertyVersion $PropertyVersion -GroupID $GroupID -ContractId $ContractId -RuleFormat $RuleFormat -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        }
    }
    catch {
        throw $_.Exception
    }

    return $PropertyRuleTree
}