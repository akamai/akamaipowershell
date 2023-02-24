function List-LDSLogEncodings
{
    Param(
        [Parameter(Mandatory=$false)] [string] [ValidateSet('email','ftp')] $DeliveryType,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('cpcode-products','gtm','edns','answerx')] $LogSourceType,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )
    
    $Path = "/lds-api/v3/log-configuration-parameters/encodings?deliveryType=$DeliveryType&logSourceType=$LogSourceType"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
