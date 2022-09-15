function Get-PropertyRuleTree
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $PropertyName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $PropertyID,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
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

    # Find property if user has specified PropertyName or version = "latest"
    if($PropertyName){
        try{
            $Property = Find-Property -PropertyName $PropertyName -latest -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            $PropertyID = $Property.propertyId
            if($PropertyID -eq ''){
                throw "Property '$PropertyName' not found"
            }
        }
        catch{
            throw $_
        }
    }

    if($PropertyVersion.ToLower() -eq "latest"){
        try{
            if($PropertyName){
                $PropertyVersion = $Property.propertyVersion
            }
            else{
                $Property = Get-Property -PropertyID $PropertyID -GroupID $GroupID -ContractId $ContractId -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
                $PropertyVersion = $Property.latestVersion
            }
        }
        catch{
            throw $_
        }
    }

    $Path = "/papi/v1/properties/$PropertyID/versions/$PropertyVersion/rules?contractId=$ContractId&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"

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
