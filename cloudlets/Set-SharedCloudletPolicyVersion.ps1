function Set-SharedCloudletPolicyVersion
{
    [CmdletBinding(DefaultParameterSetName = 'pipeline')]
    Param(
        [Parameter(Mandatory=$true) ] [string] $PolicyID,
        [Parameter(Mandatory=$true) ] [string] $Version,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$True)]  [Object] $Policy,
        [Parameter(Mandatory=$true,ParameterSetName='attributes')]  [string] $Description,
        [Parameter(Mandatory=$true,ParameterSetName='attributes')]  [object[]] $MatchRules,
        [Parameter(Mandatory=$true,ParameterSetName='postbody')]    [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        if($Version -eq 'latest'){
            $Version = (List-SharedCloudletPolicyVersions -PolicyID $PolicyID -Size 10 -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey)[0].Version
        }

        $Path = "/cloudlets/v3/policies/$PolicyID/versions/$Version`?accountSwitchKey=$AccountSwitchKey"

        if($PSCmdlet.ParameterSetName -eq 'attributes')
        {
            $BodyObj = @{
                description = $Description
                matchRules = $MatchRules
            }

            $Body = ConvertTo-Json $BodyObj -Depth 100
        }
        elseif($PSCmdlet.ParameterSetName -eq 'pipeline'){
            $Body = ConvertTo-Json $Policy -Depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $Body
            return $Result
        }
        catch {
            throw $_ 
        }
    }

    end{}
}
