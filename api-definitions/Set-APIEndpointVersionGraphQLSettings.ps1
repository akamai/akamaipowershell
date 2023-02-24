function Set-APIEndpointVersionGraphQLSettings
{
    Param(
        [Parameter(Mandatory=$true, ParameterSetName="name")] [string] $APIEndpointName,
        [Parameter(Mandatory=$true, ParameterSetName="id")]   [int] $APIEndpointID,
        [Parameter(Mandatory=$true)]  [string] $VersionNumber,
        [Parameter(Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($APIEndpointName){
        $APIEndpointID = (List-APIEndpoints -Contains $APIEndpointName -PageSize 1 -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey).apiEndPointId
    }

    if($VersionNumber.ToLower() -eq "latest"){
        $VersionNumber = (List-APIEndpointVersions -APIEndpointID $APIEndpointID -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey | Sort-Object -Property versionNumber -Descending)[0].versionNumber
    }

    $Path = "/api-definitions/v2/endpoints/$APIEndpointID/versions/$VersionNumber/settings/graphql"

    try {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_ 
    }
}
