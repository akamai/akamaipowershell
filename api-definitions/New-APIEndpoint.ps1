function New-APIEndpoint
{
    Param(
        [Parameter(Mandatory=$true, ParameterSetName="attributes")]  [string] $ApiEndPointName,
        [Parameter(Mandatory=$true, ParameterSetName="attributes")]  [string] $ApiEndPointHosts,
        [Parameter(Mandatory=$true, ParameterSetName="attributes")]  [string] $ContractId,
        [Parameter(Mandatory=$false, ParameterSetName="attributes")]  [string] $GroupId,
        [Parameter(Mandatory=$false, ParameterSetName="attributes")]  [string] $BasePath,
        [Parameter(Mandatory=$false, ParameterSetName="attributes")]  [switch] $CaseSensitive,
        [Parameter(Mandatory=$false, ParameterSetName="attributes")]  [switch] $GraphQL,
        [Parameter(Mandatory=$false, ParameterSetName="attributes")]  [object[]] $ApiResources,
        [Parameter(Mandatory=$true, ParameterSetName="postbody")]    [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/api-definitions/v2/endpoints?accountSwitchKey=$AccountSwitchKey"

    if($PSCmdlet.ParameterSetName -eq "attributes"){
        $BodyObj = @{
            apiEndPointName = $ApiEndPointName
            apiEndPointHosts = ($ApiEndPointHosts -split ",")
            contractId = $ContractId
        }

        if($GroupId)      { $BodyObj['groupId'] = [int] $GroupId }
        if($BasePath)     { $BodyObj['basePath'] = $BasePath }
        if($CaseSensitive){ $BodyObj['caseSensitive'] = $true }
        if($CaseSensitive){ $BodyObj['isGraphQL'] = $true }
        if($ApiResources){
            if($ApiResources.count -eq 1){
                $ApiResources = @($ApiResources)
            }
            $BodyObj['apiResources'] = $ApiResources 
        }

        $Body = $BodyObj | ConvertTo-Json -Depth 100
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception 
    }
}