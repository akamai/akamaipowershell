function New-CPCode
{
    Param(
        [Parameter(ParameterSetName='attributes', Mandatory=$true) ] [string] $CPCodeName,
        [Parameter(ParameterSetName='attributes', Mandatory=$true) ] [string] $ProductID,
        [Parameter(ParameterSetName='postbody', Mandatory=$true)] [string] $Body,
        [Parameter(Mandatory=$false)]  [string] $GroupId,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($PSCmdlet.ParameterSetName -eq 'attributes')
    {
        $PostObj = @{"productId" = $ProductID; "cpcodeName" = $CPCodeName}
        $Body = $PostObj | ConvertTo-Json -Dept 10
    }

    $Path = "/papi/v1/cpcodes?contractId=$ContractID&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $Body
        return $Result
    }
    catch {
        throw $_.Exception
    }
}