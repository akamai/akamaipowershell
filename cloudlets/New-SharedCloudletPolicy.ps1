function New-SharedCloudletPolicy
{
    [CmdletBinding(DefaultParameterSetName = 'attributes')]
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='attributes') ] [string] $Name,
        [Parameter(Mandatory=$false,ParameterSetName='attributes')] [string] $Description,
        [Parameter(Mandatory=$true,ParameterSetName='attributes') ] [int]    $GroupID,
        [Parameter(Mandatory=$true,ParameterSetName='attributes') ] [string] [ValidateSet('ER','FR','AS','VP2')] $CloudletType,
        [Parameter(Mandatory=$true,ParameterSetName='postbody')]    [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/cloudlets/v3/policies"

    if($PSCmdlet.ParameterSetName -eq 'attributes')
    {
        $BodyObj = @{ 
            name = $Name
            cloudletType = $CloudletType
            groupId = $GroupID
            description = $Description
            policyType = 'SHARED'
        }
        $Body = ConvertTo-Json $BodyObj -Depth 10
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
