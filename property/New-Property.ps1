function New-Property
{
    Param(
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]  [string] $PropertyName,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]  [string] $ProductID,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] $RuleFormat,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] $CloneFromVersionEtag,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [switch] $CopyHostnames,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] $ClonePropertyID,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [int]    $ClonePropertyVersion,
        [Parameter(ParameterSetName='postbody', Mandatory=$true)]    [string] $Body,
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/properties?contractId=$ContractId&groupId=$GroupID"

    if($PSCmdlet.ParameterSetName -eq 'attributes')
    {
        $PostObject = @{}
        $CloneFrom = @{}
        if($PropertyName){ $PostObject["propertyName"] = $PropertyName}
        if($ProductID){ $PostObject["productId"] = $ProductID}
        if($RuleFormat){ $PostObject["ruleFormat"] = $RuleFormat}
        if($PropertyName){ $PostObject["propertyName"] = $PropertyName}
        if($CloneFromVersionEtag){ $CloneFrom["cloneFromVersionEtag"] = $CloneFromVersionEtag}
        if($CopyHostnames){ $CloneFrom["copyHostnames"] = $CopyHostnames.ToBool()}
        if($ClonePropertyID){ $CloneFrom["propertyId"] = $ClonePropertyID}
        if($ClonePropertyVersion){ $CloneFrom["version"] = $ClonePropertyVersion}
        if($CloneFromVersionEtag -or $CopyHostnames -or $ClonePropertyID -or $ClonePropertyVersion){ $PostObject["cloneFrom"] = $CloneFrom}

        $Body = $PostObject | ConvertTo-Json -Depth 100
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey -Body $Body
        return $Result
    }
    catch {
        throw $_
    }
}
