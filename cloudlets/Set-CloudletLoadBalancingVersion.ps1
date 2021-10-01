function Set-CloudletLoadBalancingVersion
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $OriginID,
        [Parameter(Mandatory=$true)]  [string] $Version,
        [Parameter(Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [switch] $Validate,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $ValidateString = $Validate.IsPresent.ToString().ToLower()
    if(!$Validate){ $ValidateString = '' }
    
    $Path = "/cloudlets/api/v2/origins/$OriginID/versions/$Version`?validate=$ValidateString&accountSwitchKey=$AccountSwitchKey"

    $AdditionalHeaders = @{
        'Content-Type' = 'application/json'
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}