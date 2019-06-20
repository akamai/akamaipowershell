function Get-PropertyTemplates {
    Param(
        [Parameter(Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Rules = Get-PropertyRuleTree -PropertyId $PropertyId -PropertyVersion $PropertyVersion -GroupID $GroupId -ContractId $ContractId -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey

    # Make Property Directory
    $OutputDir = ".\$($Rules.propertyName)"
    if(!(Test-Path $OutputDir)) {
        New-Item -Name $OutputDir -ItemType Directory | Out-Null
    }

    for($i = 0; $i -lt $Rules.rules.children.count; $i++) {
        $Child = $Rules.rules.children[$i]
        $SafeName = $Child.Name.Replace(" ","_")
        $Child | ConvertTo-Json -depth 100 | Out-File "$outputdir\$SafeName.json" -Force
        # Convert child to include statement for main.json
        $Rules.rules.children[$i] = "#include:$SafeName.json"
    }

    $main = New-Object -TypeName PSCustomObject
    $main | Add-Member -Name "rules" -MemberType NoteProperty -Value $Rules.rules
    $main | ConvertTo-Json -depth 100 | Out-File "$OutputDir\main.json" -Force
}