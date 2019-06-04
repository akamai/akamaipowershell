function Get-CPCodeDetail
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $CPCode,
        [Parameter(Mandatory=$false)] [switch] $JSON,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/cprg/v1/cpcodes/$CPCode`?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        if($JSON)
        {
            return $Result | ConvertTo-Json -Depth 10
        }
        else
        {
            return $Result
        }
    }
    catch {
        throw $_.Exception
    }
}