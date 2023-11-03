function New-SharedCloudletPolicyVersion
{
    [CmdletBinding(DefaultParameterSetName = 'pipeline')]
    Param(
        [Parameter(Mandatory=$true) ] [string] $PolicyID,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline', ValueFromPipeline=$True)]  [Object] $Policy,
        [Parameter(Mandatory=$true,ParameterSetName='attributes')]  [string] $Description,
        [Parameter(Mandatory=$true,ParameterSetName='attributes')]  [object[]] $MatchRules,
        [Parameter(Mandatory=$true,ParameterSetName='postbody')]    [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/cloudlets/v3/policies/$PolicyID/versions"

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
            $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey -Body $Body
            return $Result
        }
        catch {
            throw $_ 
        }
    }

    end{}
}
