function Set-IDMGroupName
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true, ParameterSetName='attributes')]  [string] $GroupName,
        [Parameter(Mandatory=$true, ParameterSetName='postbody')]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/identity-management/v2/user-admin/groups/$GroupID"

    if($PSCmdlet.ParameterSetName -eq "attributes"){
        $BodyObj = @{ 'groupName' = $GroupName }
        $Body = $BodyObj | ConvertTo-Json -Depth 10
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
