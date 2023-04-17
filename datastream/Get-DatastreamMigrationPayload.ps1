function Get-DataStreamMigrationPayload
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $StreamIDs,
        [Parameter(Mandatory=$false)] [switch] $UseCommonDestination,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $UseCommonDestinationString = $UseCommonDestination.IsPresent.ToString().ToLower()
    if(!$UseCommonDestination){ $UseCommonDestinationString = '' }

    $Path = "/datastream-config-api/v1/migration/ds1-to-ds2/prepare?useCommonDestination=$UseCommonDestinationString"
    $BodyObj = @{
        streamIds = ($StreamIDs.Replace(' ','') -split ',')
    }
    $Body = $BodyObj | ConvertTo-Json

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
