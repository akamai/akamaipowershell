function New-Property
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)] [string] $PropertyName,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)] [string] $ProductID,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] $RuleFormat,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] $CloneFromVersionEtag,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [switch] $CopyHostnames,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] $ClonePropertyID,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [int] $ClonePropertyVersion,
        [Parameter(ParameterSetName='postbody', Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/properties?contractId=$ContractId&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"

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
        $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $Body
        return $Result
    }
    catch {
        throw $_.Exception
    }
}