function New-ImageManagerPolicy
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicySetAPIKey,
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('Staging', 'Production')]$Network,
        [Parameter(Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'image-manager',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($AccountSwitchKey)
    {
        Write-Host -ForegroundColor Yellow "Image Manager API currently does not support Account Switching. Sorry"
        return
        #?accountSwitchKey=$AccountSwitchKey
    }


    try {
        $ExistingPolicy = Get-ImageManagerPolicy -PolicySetAPIKey $PolicySetAPIKey -PolicyID $PolicyID -EdgeRCFile $EdgeRCFile -Section $Section -Network $Network #-AccountSwitchKey $AccountSwitchKey
        if($ExistingPolicy)
        {
            Write-Host -ForegroundColor Yellow "Polcicy $PolicyID already exists in Policy Set $PolicySetAPIKey. Nothing to do"
            return
        }
    }
    catch {
        
    }

    $Path = "/imaging/v2/policies/$PolicyID"
    $Staging = $false
    if($Network.ToLower() -eq "staging"){
        $Staging = $true
    }
    $AdditionalHeaders = @{ 'Luna-Token' = $PolicySetAPIKey }

    try {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AdditionalHeaders $AdditionalHeaders -Body $Body -Staging $Staging
        return $Result
    }
    catch {
        throw $_.Exception
    }
}

