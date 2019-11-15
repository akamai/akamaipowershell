function Get-ChildRuleTree {
    Param(
        [Parameter(Mandatory=$true)] [string] $Path
    )

    $RuleBranch = New-Object -TypeName PSCustomObject
    $Files = Get-ChildItem $Path

    # Differ on Windows or Unix paths
    if($Path.contains("\")){
        $FolderDelimiter = "\"
    }
    else{
        $FolderDelimiter = "/"
    }

    $RuleName = $Path.Substring($Path.LastIndexOf($FolderDelimiter)+1)
    $RuleBranch | Add-Member -MemberType NoteProperty -Name 'name' -Value $RuleName
    $RuleBranch | Add-Member -MemberType NoteProperty -Name 'children' -Value @()
    $RuleBranch | Add-Member -MemberType NoteProperty -Name 'behaviors' -Value @()
    $RuleBranch | Add-Member -MemberType NoteProperty -Name 'criteria' -Value @()
    $RuleBranch | Add-Member -MemberType NoteProperty -Name 'criteriaMustSatisfy' -Value 'all'
    $RuleBranch | Add-Member -MemberType NoteProperty -Name 'comments' -Value ''

    foreach($File in $Files){
        # Check files for either options or behaviors
        if($File.PSIsContainer -eq $false){
            if($File.BaseName -eq "criteria"){
                $Criteria = ConvertFrom-Json (Get-Content $File.FullName -Raw)
                # Differ on whether criteria is already an array or just a single item
                if($Criteria.Count -gt 1){
                    $RuleBranch.criteria = $Criteria
                }
                else{
                    $RuleBranch.criteria += $Criteria
                }
            }
            elseif($File.BaseName -eq "criteriaMustSatisfy"){
                $RuleBranch.criteriaMustSatisfy = ConvertFrom-Json (Get-Content $File.FullName -Raw)
            }
            elseif($File.BaseName -eq "comments"){
                $RuleBranch.comments = ConvertFrom-Json (Get-Content $File.FullName -Raw)
            }
            # Everything else is a behavior
            else{
                $RuleBranch.behaviors += ConvertFrom-Json (Get-Content $File.FullName -Raw)
            }
        }

        # Recurse through folders
        else{
            $RuleBranch.children += Get-ChildRuleTree -Path "$Path\$($File.BaseName)"
        }
    }

    return $RuleBranch
}

function Save-PropertyRuleTree
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $PropertyName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(Mandatory=$true)]  [string] $SourceFolder,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $RuleTree = New-Object -TypeName PSCustomObject

    if(!(Test-Path $SourceFolder)){
        Throw "Can't find source folder $($SourceFolder)"
    }

    $SourceFolderPath = (Get-Item $SourceFolder).FullName
    $TopLevelFiles = Get-ChildItem $SourceFolderPath

    # Initialise default rule
    $RuleTree | Add-Member -MemberType NoteProperty -Name 'rules' -Value $(New-Object -TypeName PSCustomObject)
    $RuleTree.rules | Add-Member -MemberType NoteProperty -Name 'name' -Value "default"
    $RuleTree.rules | Add-Member -MemberType NoteProperty -Name 'children' -Value @()
    $RuleTree.rules | Add-Member -MemberType NoteProperty -Name 'behaviors' -Value @()
    $RuleTree.rules | Add-Member -MemberType NoteProperty -Name 'variables' -Value @()
    $RuleTree.rules | Add-Member -MemberType NoteProperty -Name 'comments' -Value ''
    $RuleTree.rules | Add-Member -MemberType NoteProperty -Name 'options' -Value $(New-Object -TypeName PSCustomObject)

    foreach($File in $TopLevelFiles){
        # Check files for either options or behaviors
        if($File.PSIsContainer -eq $false){
            if($File.BaseName -eq "options"){
                $RuleTree.rules.options = ConvertFrom-Json (Get-Content $File.FullName -Raw)
            }
            elseif($File.BaseName -eq "variables"){
                $RuleTree.rules.variables = ConvertFrom-Json (Get-Content $File.FullName -Raw)
            }
            elseif($File.BaseName -eq "comments"){
                $RuleTree.rules.comments = ConvertFrom-Json (Get-Content $File.FullName -Raw)
            }
            # Everything else is a behavior
            else{
                $RuleTree.rules.behaviors += ConvertFrom-Json (Get-Content $File.FullName -Raw)
            }
        }

        # Recurse through folders
        else{
            $RuleTree.rules.children += Get-ChildRuleTree -Path "$SourceFolderPath$($File.BaseName)"
        }
    }

    $PostBody = $RuleTree | ConvertTo-Json -Depth 100
    $PostBody | Out-File "$PropertyName.json"

    try {
        if($PropertyName){
            $Result = Set-PropertyRuleTree -PropertyName $PropertyName -PropertyVersion $PropertyVersion -Body $PostBody -GroupID $GroupID -ContractId $ContractId -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        }
        else {
            $Result = Set-PropertyRuleTree -PropertyId $PropertyId -PropertyVersion $PropertyVersion -Body $PostBody -GroupID $GroupID -ContractId $ContractId -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        }
    }
    catch {
        throw $_.Exception
    }
    return $Result
}