<#
.SYNOPSIS
Akamai Powershell - Expanding json templates
.DESCRIPTION
Expands a single #include: statement by fetching the file and converting to PS object. You should not execute this directly, it should only be called by Merge-PropertyRuleTemplates
.PARAMETER Include
Include statement from json file
.PARAMETER Path
Folder path to prepend to include statement in order to find the file
.EXAMPLE
Expand-ChildRuleTemplate -Include "include:offload/offload.json" -Path "/property/"
.LINK
developer.akamai.com
#>

function Expand-ChildRuleTemplate {
    Param(
        [Parameter(Mandatory=$true)]  [string] $Include,
        [Parameter(Mandatory=$true)]  [string] $Path
    )

    $OSSlashChar = Get-OSSlashCharacter
    $IncludePath = $Path + $OSSlashChar + $Include.Replace("#include:","")
    $IncludeDir = $IncludePath.SubString(0,$IncludePath.LastIndexOf($OSSlashChar))
    Write-Debug "Expanding include $IncludePath"
    $Child = Get-Content $IncludePath -Raw | ConvertFrom-Json

    for($i = 0; $i -lt $Child.children.count; $i++){
        if($Child.children[$i].GetType().Name -eq 'String' -and $Child.children[$i].StartsWith('#include:')){
            $Child.children[$i] = Expand-ChildRuleTemplate -Include $Child.children[$i] -Path $IncludeDir
        }
    }

    return $Child
}

<#
.SYNOPSIS
Akamai Powershell - Expanding json templates
.DESCRIPTION
Expands a single #include: statement by fetching the file and converting to PS object. You should not execute this directly, it should only be called by Merge-PropertyRuleTemplates
.PARAMETER SourceDirectory
Folder to read property snippets from
.PARAMETER DefaultRuleFilename
Filename of json file holding default rule. Defaults to 'main.json'
.PARAMETER OutputToFile
Switch to output a json file
.PARAMETER OutputFileName
Filename to write rules to. Defaults to <foldername>.json
.EXAMPLE
Merge-PropertyRuleTemplates -SourceDirectory /property -OutputToFile -OutputFileName rules.json
.LINK
developer.akamai.com
#>

function Merge-PropertyRuleTemplates {
    Param(
        [Parameter(Mandatory=$true)]  [string] $SourceDirectory,
        [Parameter(Mandatory=$false)] [string] $DefaultRuleFilename = 'main.json',
        [Parameter(Mandatory=$false)] [switch] $OutputToFile,
        [Parameter(Mandatory=$false)] [string] $OutputFileName
    )

    $OSSlashChar = Get-OSSlashCharacter

    if(!(Test-Path "$SourceDirectory$OSSlashChar$DefaultRuleFilename")){
        throw "Default rule file '$SourceDirectory$OSSlashChar$DefaultRuleFilename' not found"
    }
    else{
        $Source = Get-Item $SourceDirectory
    }

    if($PSVersionTable.PSVersion.Major -gt 5){
        $Rules = Get-Content -Raw "$($Source.FullName)$OSSlashChar$DefaultRuleFilename" | ConvertFrom-Json -Depth 100
    }
    else{
        $Rules = Get-Content -Raw "$($Source.FullName)$OSSlashChar$DefaultRuleFilename" | ConvertFrom-Json
    }
    

    ## Get Variables
    $VariablesFileName = $Rules.variables.Replace("#include:","")
    if($PSVersionTable.PSVersion.Major -gt 5){
        $Rules.variables = Get-Content -Raw "$($Source.FullName)$OSSlashChar$VariablesFileName" | ConvertFrom-Json -Depth 100
    }
    else{
        # PS 5 does odd things with array-based json files so we have to trick it
        $Rules.variables = @()
        $Variables = Get-Content -Raw "$($Source.FullName)$OSSlashChar$VariablesFileName" | ConvertFrom-Json
        $Rules.variables += $Variables
    }
    

    for($i = 0; $i -lt $Rules.children.count; $i++){
        if($Rules.children[$i].GetType().Name -eq 'String' -and $Rules.children[$i].StartsWith('#include:')){
            $Rules.children[$i] = Expand-ChildRuleTemplate -Include $Rules.children[$i] -Path $Source.FullName
        }
    }

    $Output = New-Object -TypeName PSCustomObject
    $Output | Add-Member -MemberType NoteProperty -Name rules -Value $Rules

    if($OutputToFile){
        if($OutputFileName -eq ''){
            $OutputFileName = $Source.Name + '.json'
        }
        Write-Host "Combined contents of " -NoNewline
        Write-Host -ForegroundColor Green $SourceDirectory -NoNewline
        Write-Host " into " -NoNewline
        Write-Host -ForegroundColor Green $OutputFileName
        $Output | ConvertTo-Json -Depth 100 | Out-File $OutputFileName
    }
    else{
        return $Output
    }
}
