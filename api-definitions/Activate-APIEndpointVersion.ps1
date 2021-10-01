function Activate-APIEndpointVersion
{
    Param(
        [Parameter(Mandatory=$true)] [string] $APIEndpointName,
        [Parameter(Mandatory=$true)] [int]    $APIEndpointID,
        [Parameter(Mandatory=$true)] [string] $VersionNumber,
        [Parameter(Mandatory=$true, ParameterSetName='attributes')]  [string] $Notes,
        [Parameter(Mandatory=$true, ParameterSetName='attributes')]  [string] [ValidateSet('Production', 'Staging', 'Both')] $Networks,
        [Parameter(Mandatory=$true, ParameterSetName='attributes')]  [string] $NotificationRecipients,
        [Parameter(Mandatory=$true, ParameterSetName='postbody')]    [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($APIEndpointName){
        $APIEndpointID = (List-APIEndpoints -Contains $APIEndpointName -PageSize 1 -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey).apiEndPointId
    }

    if($VersionNumber.ToLower() -eq "latest"){
        $VersionNumber = (List-APIEndpointVersions -APIEndpointID $APIEndpointID -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey | Sort-Object -Property versionNumber -Descending)[0].versionNumber
    }

    if($PSCmdlet.ParameterSetName -eq "attributes"){
        if($Networks -eq 'Production' -or $Networks -eq 'Staging'){
            $NetworksArray = @($Networks)
        }
        else{
            $NetworksArray = @('Staging', 'Production')
        }
        $NotificationArray = $NotificationRecipients -split ","
        
        $BodyObj = @{ 
            'notes' = $Notes
            'notificationRecipients' = $NotificationArray
            'networks' = $NetworksArray
        }
        $Body = $BodyObj | ConvertTo-Json -Depth 10
    }

    $Path = "/api-definitions/v2/endpoints/$APIEndpointID/versions/$VersionNumber/activate?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception 
    }
}