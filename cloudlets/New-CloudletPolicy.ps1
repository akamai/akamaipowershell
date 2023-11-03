function New-CloudletPolicy {
    [CmdletBinding(DefaultParameterSetName = 'attributes-newpolicy')]
    Param(
        [Parameter(ParameterSetName = 'attributes-newpolicy', Mandatory)]
        [Parameter(ParameterSetName = 'attributes-clone', Mandatory)]
        [string] $Name,
    
        [Parameter(ParameterSetName = 'attributes-newpolicy')]
        [Parameter(ParameterSetName = 'attributes-clone')]
        [string] $Description,
        
        [Parameter(ParameterSetName = 'attributes-newpolicy', Mandatory)]
        [Parameter(ParameterSetName = 'attributes-clone', Mandatory)]
        [int] $GroupID,
    
        [Parameter(ParameterSetName = 'attributes-newpolicy')]
        [int] $CloudletID,
    
        [Parameter(ParameterSetName = 'attributes-clone')]
        [int] $ClonePolicyID,
    
        [Parameter(ParameterSetName = 'attributes-clone')]
        [string] $ClonePolicyVersion,
        
        [Parameter(ParameterSetName = 'postbody')] [string] $Body,
    
        [Parameter()] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter()] [string] $Section = 'default',
        [Parameter()] [string] $AccountSwitchKey
    )

    $Path = "/cloudlets/api/v2/policies"

    if ($PSCmdlet.ParameterSetName -eq 'attributes-clone') {
        $Path = "/cloudlets/api/v2/policies?clonePolicyId=$ClonePolicyID&version=$ClonePolicyVersion"
        $Post = @{ name = $Name; groupId = $GroupID; description = $Description }
        $Body = ConvertTo-Json $Post -Depth 10
    }

    if ($PSCmdlet.ParameterSetName -eq 'attributes-newpolicy') {
        $Post = @{ name = $Name; groupId = $GroupID; cloudletId = $CloudletID; description = $Description }
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
