function Export-PropertyTreeBranch
{
    Param(
        [Parameter(Mandatory=$true)]  [object] $Rules,
        [Parameter(Mandatory=$false)] [string] $Path
    )

    # Create directory
    New-Item -ItemType Directory -Path $Path | Out-Null

    # Export data
    if($Rules.criteria.Count -gt 0){
        $Rules.criteria | ConvertTo-Json -Depth 100 | Out-File "$Path\criteria.json"

        # Only export criteriaMustSatisfy if you actually have criteria
        if($Rules.criteriaMustSatisfy){
            $Rules.criteriaMustSatisfy | ConvertTo-Json -Depth 100 | Out-File "$Path\criteriaMustSatisfy.json"
        }
    }

    $Rules.behaviors | foreach {
        $_ | ConvertTo-Json -Depth 100 | Out-File "$Path\$($_.Name).json"
    }
    if($Rules.comments){
        $Rules.comments | ConvertTo-Json -Depth 100 | Out-File "$Path\comments.json"
    }

    $Rules.Children | foreach {
        Export-PropertyTreeBranch -Path "$Path\$($_.Name)" -Rules $_
    }
}

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

    $Rules = $PropertyRuleTree.rules
    $InitialPath = "$OutputFolder\$($PropertyRuleTree.propertyName)"
    
    if( (Test-Path $InitialPath) -and (Get-ChildItem $InitialPath)){
        throw "Output directory $InitialPath already exists and is not empty. Please delete its contents or choose another directory"
    }
    elseif( !(Test-Path $InitialPath) ) {
        New-Item -ItemType Directory -Path $InitialPath | Out-Null
    }

    # Export default behaviours, variables & options
    if($Rules.variables.count -gt 0){
        $Rules.variables | ConvertTo-Json -Depth 100 | Out-File "$InitialPath\variables.json"
    }
    
    if($Rules.options){
        $Rules.options | ConvertTo-Json -Depth 100 | Out-File "$InitialPath\options.json"
    }
    
    $Rules.behaviors | foreach {
        $_ | ConvertTo-Json -Depth 100 | Out-File "$InitialPath\$($_.Name).json"
    }
    if($Rules.comments){
        $Rules.comments | ConvertTo-Json -Depth 100 | Out-File "$InitialPath\comments.json"
    }
    
    # Recurse through children
    $Rules.children | foreach {
        Export-PropertyTreeBranch -Path "$InitialPath\$($_.Name)" -Rules $_
    }
}