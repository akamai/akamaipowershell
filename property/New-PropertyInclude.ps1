function New-PropertyInclude
{
    Param(
        [Parameter(ParameterSetName='attributes', Mandatory=$true)] [string] $IncludeName,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)] [string] $ProductID,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)] [string] $RuleFormat,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)] [string] [ValidateSet('MICROSERVICES','COMMON_SETTINGS')] $IncludeType,
        [Parameter(ParameterSetName='postbody', Mandatory=$true)]   [string] $Body,
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/includes?contractId=$ContractId&groupId=$GroupID"

    if($PSCmdlet.ParameterSetName -eq 'attributes')
    {
        $BodyObj = @{
            productId = $ProductID
            includeName = $IncludeName
            ruleFormat = $RuleFormat
            includeType = $IncludeType
        }
        $Body = ConvertTo-Json $BodyObj
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey -Body $Body
        return $Result
    }
    catch {
        throw $_
    }
}
