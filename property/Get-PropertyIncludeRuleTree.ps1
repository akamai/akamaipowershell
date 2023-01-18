function Get-PropertyIncludeRuleTree
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)] [string] $IncludeName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $IncludeID,
        [Parameter(Mandatory=$true)]  [string] $IncludeVersion,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $RuleFormat,
        [Parameter(Mandatory=$false)] [switch] $OutputToFile,
        [Parameter(Mandatory=$false)] [string] $OutputFileName,
        [Parameter(Mandatory=$false)] [switch] $Force,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
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

    $Path = "/papi/v1/includes/$IncludeID/versions/$IncludeVersion/rules?contractId=$ContractId&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"

    if($RuleFormat){
        $AdditionalHeaders = @{
            Accept = "application/vnd.akamai.papirules.$RuleFormat+json"
        }
    }

    try {
        $PropertyRuleTree = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
    }
    catch {
        throw $_
    }

    if($OutputToFile){
        if(!$OutputFileName){
            $OutputFileName = $PropertyRuleTree.propertyName + "_" + $PropertyRuleTree.propertyVersion + ".json"
        }
        elseif(!($OutputFileName.EndsWith(".json"))){
            $OutputFileName += ".json"
        }

        if( (Test-Path $OutputFileName) -and !$Force){
            Write-Host -ForegroundColor Yellow "Failed to write file. $OutputFileName exists and -Force not specified"
        }
        else{
            $PropertyRuleTree | ConvertTo-Json -Depth 100 | Out-File $OutputFileName -Force
            Write-Host "Wrote version " -NoNewline
            Write-Host -ForegroundColor Green $PropertyRuleTree.propertyVersion -NoNewline
            Write-Host " of property " -NoNewline
            Write-Host -ForegroundColor Green $PropertyRuleTree.propertyName -NoNewline
            Write-Host " to " -NoNewline
            Write-Host -ForegroundColor Green $OutputFileName
        }
    }
    else{
        return $PropertyRuleTree
    }
}
