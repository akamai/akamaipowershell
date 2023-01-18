function Set-IDMProperty
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PropertyID,
        [Parameter(Mandatory=$true, ParameterSetName='attributes')]  [int] $SourceGroupID,
        [Parameter(Mandatory=$true, ParameterSetName='attributes')]  [int] $DestinationGroupID,
        [Parameter(Mandatory=$true, ParameterSetName='postbody')]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/identity-management/v2/user-admin/properties/$PropertyID`?accountSwitchKey=$AccountSwitchKey"

    if($PSCmdlet.ParameterSetName -eq "attributes"){
        $BodyObj = @{ 
            'sourceGroupId' = $SourceGroupID
            'destinationGroupId' = $DestinationGroupID
        }
        $Body = $BodyObj | ConvertTo-Json -Depth 10
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}
