<#
.SYNOPSIS
Akamai Powershell - Splitting out properties to snippets
.DESCRIPTION
Pulls a property rule tree from PAPI and breaks it down into json snippets, to a specified depth
.PARAMETER IncludeName
Include name to read from PAPI. Either this or IncludeID is required
.PARAMETER IncludeID
Include ID to read from PAPI. Either this or IncludeName is required
.PARAMETER IncludeVersion
Version of include to read from PAPI. Can be integer or 'latest'
.PARAMETER OutputDir
Folder to write snippets to. Defaults to the include name. OPTIONAL
.PARAMETER MaxDepth
Depth of recursion. Defaults to 100, which is effectively unlimited. OPTIONAL
.PARAMETER GroupID
PAPI group for the property. OPTIONAL
.PARAMETER ContractId
PAPI contract from the property. OPTIONAL
.PARAMETER EdgeRCFile
Path to .edgerc file, defaults to ~/.edgerc. OPTIONAL
.PARAMETER ContractId
.edgerc Section name. Defaults to 'default'. OPTIONAL
.PARAMETER AccountSwitchKey
Account switch key if applying to an account external to yoru API user. Only usable by Akamai staff and partners. OPTIONAL
.EXAMPLE
Get-PropertyRuleTemplates -IncludeName MyInclude -IncludeVersion latest -OutputDir MyInclude
.LINK
developer.akamai.com
#>

function Get-PropertyIncludeRuleTemplates {
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $IncludeName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $IncludeID,
        [Parameter(Mandatory=$true)]  [string] $IncludeVersion,
        [Parameter(Mandatory=$false)] [string] $OutputDir,
        [Parameter(Mandatory=$false)] [int]    $MaxDepth = 100,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($IncludeName){
        $Include = Find-Property -IncludeName $IncludeName -latest -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        if($null -eq $Include){
            throw "Include '$IncludeName' not found"
        }
        $IncludeID = $Include.includeId
    }

    if($IncludeVersion.ToLower() -eq "latest"){
        if($IncludeName -eq ''){
            $Include = Find-Property -IncludeName $IncludeName -latest -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        }
        $IncludeVersion = $Include.includeVersion
    }

    $Rules = Get-PropertyIncludeRuleTree -IncludeID $IncludeID -IncludeVersion $IncludeVersion -GroupID $GroupId -ContractId $ContractId -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey

    if($OutputDir -eq ''){
        $OutputDir = $Rules.includeName
    }
    
    # Make Property Directory if required
    if(!(Test-Path $OutputDir)) {
        Write-Host "Creating new property include directory " -NoNewLine
        Write-Host -ForegroundColor Cyan $OutputDir
        New-Item -Name $OutputDir -ItemType Directory | Out-Null
    }

    for($i = 0; $i -lt $Rules.rules.children.count; $i++) {
        Get-ChildRuleTemplate -Rules $Rules.rules.children[$i] -Path $OutputDir -CurrentDepth 0 -MaxDepth $MaxDepth
        $SafeName = Sanitise-FileName -FileName $Rules.rules.children[$i].Name
        $Rules.rules.children[$i] = "#include:$SafeName.json"
    }

    ### Split variables out to its own file
    if($null -ne $Rules.rules.variables){
        ConvertTo-Json -depth 100 $Rules.rules.variables | Out-File "$outputdir\pmVariables.json" -Force
        $Rules.rules.variables = "#include:pmVariables.json"
    }

    ### Write default rule to main file
    $Rules.rules | ConvertTo-Json -depth 100 | Out-File "$outputdir\main.json" -Force

    Write-Host "Wrote version " -NoNewLine
    Write-Host -ForegroundColor Cyan $Rules.includeVersion -NoNewline
    Write-Host " of property include " -NoNewline
    Write-Host  -ForegroundColor Cyan $Rules.includeName -NoNewline
    Write-Host " to " -NoNewline
    Write-Host  -ForegroundColor Cyan $OutputDir
}
