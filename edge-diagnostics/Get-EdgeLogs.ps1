function Get-EdgeLogs
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $EdgeIP,
        [Parameter(Mandatory=$true)]  [int]    $CPCode,
        [Parameter(Mandatory=$false)] [string] $ClientIP,
        [Parameter(Mandatory=$false)] [string] $ObjectStatus,
        [Parameter(Mandatory=$false)] [string] $HttpStatusCode,
        [Parameter(Mandatory=$false)] [string] $UserAgent,
        [Parameter(Mandatory=$false)] [string] $ARL,
        [Parameter(Mandatory=$false)] [string] $Start,
        [Parameter(Mandatory=$true)]  [string] $End,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('R','F')] $LogType,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $ISO8601Match = '[\d]{4}-[\d]{2}-[\d]{2}(T[\d]{2}:[\d]{2}(:[\d]{2})?(Z|[+-]{1}[\d]{2}[:][\d]{2})?)?'
    if($Start -ne ''){
        if($Start -notmatch $ISO8601Match){
            throw "ERROR: Start & End must be in the format 'YYYY-MM-DDThh:mm(:ss optional) and (optionally) end with: 'Z' for UTC or '+/-XX:XX' to specify another timezone"
        }
    }
    if($End -ne ''){
        if($End -notmatch $ISO8601Match){
            throw "ERROR: Start & End must be in the format 'YYYY-MM-DDThh:mm(:ss optional) and (optionally) end with: 'Z' for UTC or '+/-XX:XX' to specify another timezone"
        }
    }

    $Path = "/edge-diagnostics/v1/grep?edgeIp=$EdgeIP&cpCode=$CPCode&clientIp=$ClientIP&objectStatus=$ObjectStatus&httpStatusCode=$HTTPStatusCode&userAgent=$UserAgent&arl=$ARL&start=$Start&end=$End&logType=$LogType"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
