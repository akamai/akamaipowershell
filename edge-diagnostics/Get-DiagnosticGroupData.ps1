function Get-DiagnosticGroupData
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$false)] [switch] $IncludeCurl,
        [Parameter(Mandatory=$false)] [switch] $IncludeDig,
        [Parameter(Mandatory=$false)] [switch] $IncludeMTR,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $IncludeCurlString = $IncludeCurl.IsPresent.ToString().ToLower()
    if(!$IncludeCurl){ $IncludeCurlString = '' }
    $IncludeDigString = $IncludeDig.IsPresent.ToString().ToLower()
    if(!$IncludeDig){ $IncludeDigString = '' }
    $IncludeMTRString = $IncludeMTR.IsPresent.ToString().ToLower()
    if(!$IncludeMTR){ $IncludeMTRString = '' }

    $Path = "/edge-diagnostics/v1/user-diagnostic-data/groups/$GroupID/records?includeCurl=$IncludeCurlString&includeDig=$IncludeDigString&includeMtr=$IncludeMTRString&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}