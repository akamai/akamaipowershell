function New-CloudletPolicy
{
    Param(
        [Parameter(ParameterSetName='attributes', Mandatory=$true) ] [string] $Name,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] $Description,
        [Parameter(ParameterSetName='attributes', Mandatory=$true) ] [int]    $GroupID,
        [Parameter(ParameterSetName='attributes', Mandatory=$true) ] [int]    $CloudletID,
        [Parameter(ParameterSetName='postbody', Mandatory=$false)]   [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/cloudlets/api/v2/policies?accountSwitchKey=$AccountSwitchKey"

    if($PSCmdlet.ParameterSetName -eq 'attributes')
    {
        $BodyObj = @{ 
            name = $Name
            cloudletId = $CloudletID
            groupId = $GroupID
            description = $Description
            policyType = 'SHARED'
        }
        $Body = ConvertTo-Json $BodyObj -Depth 10
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}