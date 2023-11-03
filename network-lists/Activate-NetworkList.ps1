function Activate-NetworkList
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $NetworkListID,
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('PRODUCTION','STAGING')] $Environment = 'PRODUCTION',
        [Parameter(Mandatory=$false)] [string] $Comments,
        [Parameter(Mandatory=$false)] [string] $NotificationRecipients,
        [Parameter(Mandatory=$false)] [string] $SiebelTicketID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/network-list/v2/network-lists/$NetworkListId/environments/$Environment/activate"

    $BodyObj = @{}
    if($Comments){
        $BodyObj['comments'] = $Comments
    }
    if($NotificationRecipients){
        $NotificationsArray = $NotificationRecipients -split ","
        $BodyObj['notificationRecipients'] = $NotificationsArray
    }
    if($SiebelTicketID){
        $BodyObj['siebelTicketId'] = $SiebelTicketID
    }

    $Body = $BodyObj | ConvertTo-Json -Depth 100

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Body $Body -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
