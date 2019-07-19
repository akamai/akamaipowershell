function Set-IDMGroupName
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true, ParameterSetName='attributes')]  [string] $GroupName,
        [Parameter(Mandatory=$true, ParameterSetName='postbody')]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/identity-management/v2/user-admin/groups/$GroupID`?accountSwitchKey=$AccountSwitchKey"

    if($PSCmdlet.ParameterSetName -eq "attributes"){
        $BodyObj = @{ 'groupName' = $GroupName }
        $Body = $BodyObj | ConvertTo-Json -Depth 10
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}