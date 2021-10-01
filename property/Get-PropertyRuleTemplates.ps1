function Get-ChildRuleTemplate {
    Param(
        [Parameter(Mandatory=$true)] [object] $Rules,
        [Parameter(Mandatory=$true)] [string] $Path,
        [Parameter(Mandatory=$true)] [int]    $CurrentDepth,
        [Parameter(Mandatory=$true)] [int]    $MaxDepth
    )
    
    $SafeName = Sanitise-FileName -FileName $Rules.Name
    $CurrentPath = "$Path\$SafeName"
    $NewDepth = $CurrentDepth++

    if(!(Test-Path $CurrentPath)) {
        New-Item -Name $CurrentPath -ItemType Directory | Out-Null
    }

    for($i = 0; $i -lt $Rules.children.count; $i++) {
        if($CurrentDepth -le $MaxDepth){
            Get-ChildRuleTemplate -Rules $Rules.children[$i] -Path $CurrentPath -CurrentDepth $NewDepth -MaxDepth $MaxDepth
            $SafeChildName = Sanitise-FileName -FileName $Rules.children[$i].Name
            $Rules.children[$i] = "#include:$SafeChildName\$SafeChildName.json"
        }
    }

    $Rules | ConvertTo-Json -Depth 100 | Out-File "$CurrentPath\$SafeName.json"
}

function Get-PropertyRuleTemplates {
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $PropertyName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(Mandatory=$false)] [string] $OutputDir,
        [Parameter(Mandatory=$false)] [int]    $MaxDepth = 100,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($PropertyName){
        try{
            $Property = Find-Property -PropertyName $PropertyName -latest -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            $PropertyID = $Property.propertyId
            if($PropertyID -eq ''){
                throw "Property '$PropertyName' not found"
            }
        }
        catch{
            throw $_.Exception
        }
    }

    $Rules = Get-PropertyRuleTree -PropertyId $PropertyId -PropertyVersion $PropertyVersion -GroupID $GroupId -ContractId $ContractId -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey

    if($OutputDir -eq ''){
        $OutputDir = $Rules.propertyName
    }
    
    # Make Property Directory if required
    if(!(Test-Path $OutputDir)) {
        Write-Host "Creating new property directory " -NoNewLine
        Write-Host -ForegroundColor Cyan $OutputDir
        New-Item -Name $OutputDir -ItemType Directory | Out-Null
    }

    for($i = 0; $i -lt $Rules.rules.children.count; $i++) {
        Get-ChildRuleTemplate -Rules $Rules.rules.children[$i] -Path $OutputDir -CurrentDepth 0 -MaxDepth $MaxDepth
        $SafeName = Sanitise-FileName -FileName $Rules.rules.children[$i].Name
        $Rules.rules.children[$i] = "#include:$SafeName\$SafeName.json"
    }

    $Rules.rules | ConvertTo-Json -depth 100 | Out-File "$outputdir\main.json" -Force

    Write-Host "Wrote version " -NoNewLine
    Write-Host -ForegroundColor Cyan $Rules.propertyVersion -NoNewline
    Write-Host " of property " -NoNewline
    Write-Host  -ForegroundColor Cyan $Rules.propertyName -NoNewline
    Write-Host " to " -NoNewline
    Write-Host  -ForegroundColor Cyan $OutputDir
}