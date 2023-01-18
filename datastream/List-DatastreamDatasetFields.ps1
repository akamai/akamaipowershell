function List-DatastreamDatasetFields
{
    Param(
        [Parameter(Mandatory=$false)] [string] $ProductID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/datastream-config-api/v2/log/datasets-fields?productId=$ProductID&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.datasetFields
    }
    catch {
        throw $_
    }
}

Set-Alias -Name List-DS2DatasetFields -Value List-DatastreamDatasetFields
