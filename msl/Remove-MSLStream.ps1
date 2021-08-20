function Remove-MSLStream
{
    Param(
        [Parameter(Mandatory=$true)]  [int]    $StreamID,
        [Parameter(Mandatory=$false)] [switch] $PurgeContent,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $PurgeContentString = $PurgeContent.IsPresent.ToString().ToLower()
    if(!$PurgeContent){ $PurgeContentString = '' }

    $Path = "/config-media-live/v2/msl-origin/streams/$StreamID`?purgeContent=$PurgeContentString&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method DELETE -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
              
}