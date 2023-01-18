function Remove-PropertyInclude
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $IncludeName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $IncludeID,
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

    $Path = "/papi/v1/includes/$IncludeID`?contractId=$ContractId&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method DELETE -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}
