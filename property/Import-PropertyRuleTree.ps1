function Import-RuleTree
{
    Param(
        [Parameter(Mandatory=$true)] [object] $Rules,
        [Parameter(Mandatory=$true)] [string] $Path
    )

    # Create directory
    New-Item -ItemType Directory -Path $Path | Out-Null

    # Create Index Object
    $Index = New-Object -TypeName PSCustomObject
    $Index | Add-Member -MemberType NoteProperty -Name "children" -Value @()
    $Index | Add-Member -MemberType NoteProperty -Name "behaviors" -Value @()

    # Variables
    if($Rules.variables.count -gt 0){
        $Rules.variables | ConvertTo-Json -Depth 100 | Out-File "$InitialPath\variables.json"
    }
    
    # Options
    if($Rules.options){
        $Rules.options | ConvertTo-Json -Depth 100 | Out-File "$InitialPath\options.json"
    }

    # Criteria & cirteriaMustSatisfy
    if($Rules.criteria.Count -gt 0){
        $Rules.criteria | ConvertTo-Json -Depth 100 | Out-File "$Path\criteria.json"

        # Only export criteriaMustSatisfy if you actually have criteria
        if($Rules.criteriaMustSatisfy){
            $Rules.criteriaMustSatisfy | ConvertTo-Json -Depth 100 | Out-File "$Path\criteriaMustSatisfy.json"
        }
    }

    # Behaviors
    foreach($Behavior in $Rules.behaviors){
        $MatchingBehaviors = $Rules.behaviors | where {$_.Name -eq $Behavior.Name}
        # Look for multiple behaviors of the same name and append numerical value to its name
        if($MatchingBehaviors.count -gt 1){
            for($i = 0; $i -lt $MatchingBehaviors.count; $i++){
                if($Behavior -eq $MatchingBehaviors[$i]){
                    $NamingIndex = $i + 1 # Start at 1, rather than 0
                }
            }
            $Behavior | ConvertTo-Json -Depth 100 | Out-File "$Path\$($Behavior.Name)-$NamingIndex.json"
            $Index.behaviors += $Behavior.Name + "-$NamingIndex"
        }
        else{
            $Behavior | ConvertTo-Json -Depth 100 | Out-File "$Path\$($Behavior.Name).json"
            $Index.behaviors += $Behavior.Name
        }
    }

    # Comments
    if($Rules.comments){
        $Rules.comments | ConvertTo-Json -Depth 100 | Out-File "$Path\comments.json"
    }

    # Recurse through children
    $Rules.Children | foreach {
        Import-RuleTree -Path "$Path\$($_.Name)" -Rules $_
        $Index.children += $_.Name
    }

    # Save Index
    $Index | ConvertTo-Json -Depth 100 | Out-File "$Path\index.json"

}

function Import-PropertyRuleTree
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $PropertyName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(Mandatory=$false)] [string] $OutputFolder = ".",
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $RuleFormat,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Get Property from PAPI
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
    $FullOutputFolder = (Get-Item $OutputFolder).FullName
    $InitialPath = "$FullOutputFolder\$($PropertyRuleTree.propertyName)"
    
    if(Test-Path $InitialPath){
        $FullInitialPath = (Get-Item $InitialPath).FullName
        throw "Output directory $FullInitialPath already exists. Please delete it or choose another directory"
    }

    # Run recursive sub-function
    Import-RuleTree -Path "$InitialPath" -Rules $Rules

    Write-Host -ForegroundColor Green "Saved property '$($PropertyRuleTree.propertyName):$($PropertyRuleTree.propertyVersion)' to $InitialPath"
}