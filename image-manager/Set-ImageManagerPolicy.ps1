function Set-ImageManagerPolicy
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicySetAPIKey,
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('Staging', 'Production')] $Network,
        [Parameter(Mandatory=$false)] [string] $ContractID,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)] [object] $Policy,
        [Parameter(Mandatory=$false,ParameterSetName='pipeline')] [int] $RolloutDuration,
        [Parameter(Mandatory=$true,ParameterSetName='body')] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Network = $Network.ToLower()
        $Path = "/imaging/v2/network/$Network/policies/$PolicyID"
        $AdditionalHeaders = @{ 'Luna-Token' = $PolicySetAPIKey }

        if($ContractID -ne ''){
            $AdditionalHeaders['Contract'] = $ContractID
        }

        if($Policy){
            if($RolloutDuration){
                $Policy | Add-Member -MemberType NoteProperty -Name rolloutDuration -Value $RolloutDuration -Force
            }
            $Body = $Policy | ConvertTo-Json -Depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            return $Result
        }
        catch {
            throw $_
        }
    }

    end{}  
}
