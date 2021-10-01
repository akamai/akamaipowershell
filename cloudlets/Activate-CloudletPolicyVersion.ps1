function Activate-CloudletPolicyVersion
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$true)]  [string] $Version,
        [Parameter(Mandatory=$false)] [string] $AdditionalPropertyNames,
        [Parameter(Mandatory=$false)] [string] $Network = 'production',
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($Version -eq 'latest'){
        $Version = (List-CloudletPolicyVersions -PolicyID $PolicyID -Pagesize 1 -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey).Version
        Write-Debug "Found latest version = $Version"
    }

    $Path = "/cloudlets/api/v2/policies/$PolicyID/versions/$Version/activations?accountSwitchKey=$AccountSwitchKey"

    $Body = @{ network = $Network }
    if($AdditionalPropertyNames){
        $Body['additionalPropertyNames'] = @()
        $AdditionalPropertyNames.split(",") | foreach {
            $Body['additionalPropertyNames'] += $_
        }
    }
    $JsonBody = $Body | ConvertTo-Json -Depth 100

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $JsonBody
        return $Result
    }
    catch {
        throw $_.Exception
    }
}