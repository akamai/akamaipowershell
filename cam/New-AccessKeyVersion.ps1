function New-AccessKeyVersion
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $AccessKeyUID,
        [Parameter(Mandatory=$true)]  [string] $CloudAccessKeyID,
        [Parameter(Mandatory=$true)]  [string] $CloudSecretAccessKey,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/cam/v1/access-keys/$AccessKeyUID/versions?accountSwitchKey=$AccountSwitchKey"

    $BodyObj = @{
        cloudAccessKeyId = $CloudAccessKeyID
        cloudSecretAccessKey = $CloudSecretAccessKey
    }
    $Body = ConvertTo-Json $BodyObj

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}