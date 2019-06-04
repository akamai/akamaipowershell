function Get-ImageManagerPolicyHistory
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicySetAPIKey,
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('Staging', 'Production')]$Network,
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

    $Path = "/imaging/v2/policies/history/$PolicyID"
    $Staging = $false
    if($Network.ToLower() -eq "staging"){
        $Staging = $true
    }
    $AdditionalHeaders = @{ 'Luna-Token' = $PolicySetAPIKey }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AdditionalHeaders $AdditionalHeaders -Staging $Staging
        return $Result.items
    }
    catch {
        throw $_.Exception
    }
}

