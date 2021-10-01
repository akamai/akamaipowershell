function New-ImageManagerPolicy
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicySetAPIKey,
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('Staging', 'Production')] $Network,
        [Parameter(Mandatory=$false)] [string] $ContractID,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)] [object] $Policy,
        [Parameter(Mandatory=$true,ParameterSetName='body')] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{
        try {
            $ExistingPolicy = Get-ImageManagerPolicy -PolicySetAPIKey $PolicySetAPIKey -PolicyID $PolicyID -Network $Network -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            if($ExistingPolicy)
            {
                throw "Polcicy $PolicyID already exists in Policy Set $PolicySetAPIKey"
            }
        }
        catch {
            
        }
    }

    process{
        $Network = $Network.ToLower()
        $Path = "/imaging/v2/network/$Network/policies/$PolicyID`?accountSwitchKey=$AccountSwitchKey"
        $AdditionalHeaders = @{ 'Luna-Token' = $PolicySetAPIKey }

        if($ContractID -ne ''){
            $AdditionalHeaders['Contract'] = $ContractID
        }

        if($Policy){
            $Body = $Policy | ConvertTo-Json -Depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_.Exception
        }
    }

    end{}
}

