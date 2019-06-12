#************************************************************************
#
#	Name: Get-ReportData.ps1
#	Author: S Macleod
#	Purpose: Calls {OPEN} Reporting API and dumps out data for given report
#	Date: 13/05/2019
#	Version: 1 - Initial
#
#************************************************************************

Param(
    [Parameter(Mandatory=$true)]  [string] $ReportType,
    [Parameter(Mandatory=$false)]  [int] $Version = 1,
    [Parameter(Mandatory=$true)]  [string] $CpCodes,
    [Parameter(Mandatory=$false)] [switch] $LastWeek,
    [Parameter(Mandatory=$false)] [switch] $LastMonth,
    [Parameter(Mandatory=$false)] [switch] $Last90Days,
    [Parameter(Mandatory=$false)] [int] $LastXDays,
    [Parameter(Mandatory=$false)] [int] $Limit = 500,
    [Parameter(Mandatory=$false)] [string] $Section = 'default',
    [Parameter(Mandatory=$true)]  [string] $AccountSwitchKey
    )

Import-Module ImportExcel

if(!(Get-Module AkamaiPowershell))
{
    Write-Host -ForegroundColor Yellow "Please import the Akamai Powershell module before running this script"
    return
}

$Now = (Get-Date -Hour 0 -Minute 00 -Second 00).ToUniversalTime()
$EndDate = $Now.AddDays(-1)

if($LastWeek)
{
    $StartDate = $Now.AddDays(-7)
}
elseif($LastMonth)
{
    $StartDate = $Now.AddMonths(-1)
}
elseif($Last90Days)
{
    $StartDate = $Now.AddDays(-90)
}
elseif($LastXDays)
{
    $StartDate = $Now.AddDays(-$LastXDays)
}
else {
    Write-Host -ForegroundColor Yellow "You must specify a duration. Either LastWeek, LastMonth or Last90Days"
    return
}

$StartString = "$($StartDate.Year)-$($StartDate.Month.ToString('00'))-$($StartDate.Day.ToString('00'))T00:00:00Z"
$EndString = "$($EndDate.Year)-$($EndDate.Month.ToString('00'))-$($EndDate.Day.ToString('00'))T00:00:00Z"


try {
    $Data = Get-CacheableReport -ReportType $ReportType -Version $Version -Start $StartString -End $EndString -Interval DAY -ObjectType cpcode -ObjectIds $CPCodes -limit $Limit -AccountSwitchKey $AccountSwitchKey -Section $Section -ErrorAction Stop
}
catch {
    try {
        Write-Host "Issue retrieving report data first time. Retrying..."
        $Data = Get-CacheableReport -ReportType $ReportType -Version $Version -Start $StartString -End $EndString -Interval DAY -ObjectType cpcode -ObjectIds $CPCodes -limit $Limit -AccountSwitchKey $AccountSwitchKey -Section $Section -ErrorAction Stop
        Write-Host "Successfully retrieved report data" -ForegroundColor Green
    }
    catch {
        Write-Host -ForegroundColor Red "ERROR: Could not retrieve report data from Akamai"
        Write-Host $_
        return
    }
}

return $Data