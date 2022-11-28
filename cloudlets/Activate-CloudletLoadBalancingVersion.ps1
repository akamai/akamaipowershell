function Activate-CloudletLoadBalancingVersion
{
    [CmdletBinding(DefaultParameterSetName = 'attributes')]
    Param(
        [Parameter(Mandatory=$true)]  [string] $OriginID,
        [Parameter(Mandatory=$true,ParameterSetName='attributes')]  [ValidateSet('STAGING','PRODUCTION')] [string] $Network,
        [Parameter(Mandatory=$true,ParameterSetName='attributes')]  [string] $Version,
        [Parameter(Mandatory=$false,ParameterSetName='attributes')] [switch] $DryRun,
        [Parameter(Mandatory=$true,ParameterSetName='postbody')]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/cloudlets/api/v2/origins/$OriginID/activations?accountSwitchKey=$AccountSwitchKey"

    if($PSCmdlet.ParameterSetName -eq "attributes"){
        if($Version -eq 'latest'){
            $Versions = List-CloudletLoadBalancingVersions -OriginID $OriginID -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            $Versions = $Versions | Sort-Object -Property Version -Descending
            $Version = $Versions[0].version
        }

        $BodyObj = @{
            network = $Network.ToUpper()
            version = $Version
            dryrun = $DryRun.IsPresent
        }
        $Body = $BodyObj | ConvertTo-Json
    }

    $AdditionalHeaders = @{
        'Content-Type' = 'application/json'
    }
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}