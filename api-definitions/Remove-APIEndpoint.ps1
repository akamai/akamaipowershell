function Remove-APIEndpoint
{
    Param(
        [Parameter(Mandatory=$true, ParameterSetName="name")] [string] $APIEndpointName,
        [Parameter(Mandatory=$true, ParameterSetName="id")]   [int] $APIEndpointID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($APIEndpointName){
        $APIEndpointID = (List-APIEndpoints -Contains $APIEndpointName -PageSize 1 -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey).apiEndPointId
    }

    $Path = "/api-definitions/v2/endpoints/$APIEndpointID`?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method DELETE -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_ 
    }
}
