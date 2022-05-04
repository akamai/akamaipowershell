function New-SharedCloudletPolicyVersion
{
    Param(
        [Parameter(Mandatory=$true) ] [string] $PolicyID,
        [Parameter(Mandatory=$true) ] [string] $Version,
        [Parameter(ParameterSetName='pipeline', ValueFromPipeline=$True, Mandatory=$true)]  [Object] $Policy,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]  [string] $Description,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]  [object[]] $MatchRules,
        [Parameter(ParameterSetName='postbody', Mandatory=$false)]   [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        if($Version -eq 'latest'){
            $Version = (List-CloudletPolicyVersions -PolicyID $PolicyID -Pagesize 1 -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey).Version
            Write-Debug "Found latest version = $Version"
        }

        $Path = "/cloudlets/v3/policies/$PolicyID/versions?accountSwitchKey=$AccountSwitchKey"

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