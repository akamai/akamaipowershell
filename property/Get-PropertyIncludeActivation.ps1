function Get-PropertyIncludeActivation
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)] [string] $IncludeName,
        [Parameter(ParameterSetName="id", Mandatory=$true)] [string] $IncludeID,
        [Parameter(Mandatory=$true)]  [string] $ActivationID,
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

    $Path = "/papi/v1/includes/$IncludeID/activations/$ActivationID`?contractId=$ContractId&groupId=$GroupID"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.activations.items
    }
    catch {
        throw $_
    }
}
