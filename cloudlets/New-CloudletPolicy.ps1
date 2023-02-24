function New-CloudletPolicy
{
    [CmdletBinding(DefaultParameterSetName = 'attributes')]
    Param(
        [Parameter(ParameterSetName='attributes', Mandatory=$true) ] [string] $Name,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] $Description,
        [Parameter(ParameterSetName='attributes', Mandatory=$true) ] [int]    $GroupID,
        [Parameter(ParameterSetName='attributes', Mandatory=$true) ] [int]    $CloudletID,
        [Parameter(ParameterSetName='postbody', Mandatory=$false)]   [string] $Body,
        [Parameter(Mandatory=$false)] [int]    $ClonePolicyID,
        [Parameter(Mandatory=$false)] [string] $ClonePolicyVersion,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/cloudlets/api/v2/policies?clonepolicyid=$ClonePolicyID&version=$ClonePolicyVersion"

    if($PSCmdlet.ParameterSetName -eq 'attributes')
    {
        $Post = @{ name = $Name; cloudletId = $CloudletID; groupId = $GroupID; description = $Description }
        $Body = ConvertTo-Json $Post -Depth 10
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey -Body $Body
        return $Result
    }
    catch {
        throw $_
    }
}
