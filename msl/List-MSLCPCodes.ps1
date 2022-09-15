function List-MSLCPCodes
{
    Param(
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('INGEST','DELIVERY','STORAGE')] $Type,
        [Parameter(Mandatory=$false)] [switch] $Unused,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $UnusedString = $Unused.IsPresent.ToString().ToLower()
    if(!$Unused){ $UnusedString = '' }


    $Path = "/config-media-live/v2/msl-origin/cpcodes?type=$Type&unused=$UnusedString&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
              
}
