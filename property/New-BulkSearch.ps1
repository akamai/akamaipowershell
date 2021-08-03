function New-BulkSearch
{
    Param(
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]  [string] $Match,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] $BulkSearchQualifier,
        [Parameter(ParameterSetName='postbody', Mandatory=$true)]    [string] $Body,
        [Parameter(Mandatory=$false)] [switch] $Synchronous,
        [Parameter(Mandatory=$false)] [string] $GroupId,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Endpoint = 'rules-search-requests'
    if($Synchronous){
        $Endpoint += '-synch'
    }
    $Path = "/papi/v1/bulk/$Endpoint`?contractId=$ContractID&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"

    if($PSCmdlet.ParameterSetName -eq 'attributes')
    {
        $BulkSearchQuery = @{
            'syntax' = 'JSONPATH'
            'match' = $Match
        }
        if($BulkSearchQualifier){
            $BulkSearchQuery['bulkSearchQualifiers'] = @($BulkSearchQualifier)
        }
        $BodyObj = @{'bulkSearchQuery' = $BulkSearchQuery}
        $Body = $BodyObj | ConvertTo-Json -depth 100
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}