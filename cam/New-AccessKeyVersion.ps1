function New-AccessKeyVersion
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $AccessKeyUID,
        [Parameter(Mandatory=$true)]  [string] $CloudAccessKeyID,
        [Parameter(Mandatory=$true)]  [string] $CloudSecretAccessKey,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/cam/v1/access-keys/$AccessKeyUID/versions"

    $BodyObj = @{
        cloudAccessKeyId = $CloudAccessKeyID
        cloudSecretAccessKey = $CloudSecretAccessKey
    }
    $Body = ConvertTo-Json $BodyObj

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
