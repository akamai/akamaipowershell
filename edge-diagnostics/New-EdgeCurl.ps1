function New-EdgeCurl
{
    [CmdletBinding(DefaultParameterSetName = 'ip')]
    Param(
        [Parameter(Mandatory=$true)]  [string] $URL,
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('IPV4','IPV6')] $IPVersion,
        [Parameter(Mandatory=$false,ParameterSetName='ip')]  [string] $EdgeIP,
        [Parameter(Mandatory=$false,ParameterSetName='location')] [string] $EdgeLocation,
        [Parameter(Mandatory=$false)] [string] $SpoofEdgeIP,
        [Parameter(Mandatory=$false)] [string] $RequestHeaders,
        [Parameter(Mandatory=$false)] [switch] $RunFromSiteshield,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edge-diagnostics/v1/curl?accountSwitchKey=$AccountSwitchKey"

    $BodyObj = @{
        url = $URL
        ipVersion = $IPVersion
    }


    if($EdgeIP -ne ''){
        $BodyObj['edgeIp'] = $EdgeIP 
    }

    if($EdgeLocation -ne ''){
        $BodyObj['edgeLocation'] = $EdgeLocation 
    }

    if($SpoofEdgeIP -ne ''){
        $BodyObj['spoofEdgeIP'] = $SpoofEdgeIP 
    }

    if($RequestHeaders -ne ''){
        $BodyObj['requestHeaders'] = @()
        $RequestHeaders -split ',' | foreach {
            $BodyObj['requestHeaders'] += $_
        }
    }

    if($RunFromSiteshield){
        $BodyObj['runFromSiteshield'] = $true 
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