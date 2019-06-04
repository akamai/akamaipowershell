function Update-CPCode
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $CPCode,
        [Parameter(Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Test JSON if PS 6 or higher
    if($PSVersionTable.PSVersion.Major -ge 6)
    {
        if(!(Test-JSON $Body))
        {
            return "ERROR: Body is not valid JSON"
        }
    }

    $Path = "/cprg/v1/cpcodes/$CPCode`?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $Body
        return $Result
    }
    catch {
        Write-Host "Error updating CP Code $CPCode"
        throw $_.Exception
    }
}

