function Get-EdgeErrorStatistics
{
    [CmdletBinding(DefaultParameterSetName = 'cpcode')]
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='cpcode')]  [int]    $CPCode,
        [Parameter(Mandatory=$true,ParameterSetName='url')]     [string] $URL,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('EDGE_ERRORS','ORIGIN_ERRORS')] $ErrorType,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('STANDARD_TLS','ENHANCED_TLS')] $Delivery,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edge-diagnostics/v1/estats?accountSwitchKey=$AccountSwitchKey"
    $BodyObj = @{}
    if($CPCode){
        $BodyObj['cpCode'] = $CPCode
    }
    if($URL -ne ''){
        $BodyObj['url'] = $URL
    }
    if($ErrorType -ne ''){
        $BodyObj['errorType'] = $ErrorType
    }
    if($Delivery -ne ''){
        $BodyObj['delivery'] = $Delivery
    }
    
    $Body = ConvertTo-Json $BodyObj

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}