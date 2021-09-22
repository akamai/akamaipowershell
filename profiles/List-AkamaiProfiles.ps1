<#
.SYNOPSIS
EdgeGrid Powershell
.DESCRIPTION
Lists profiles stored on disk, either in the default path or a specified one.
.PARAMETER ProfilePath
On-disk location of profiles JSON file
.EXAMPLE
List-AkamaiProfiles
.LINK
developer.akamai.com
#>
function List-AkamaiProfiles
{
    param(
        [Parameter(Mandatory=$false)] [String] $ProfilePath = '~/.akamai-cli/akamaipowershell.json'
    )

    if(! (Test-Path $ProfilePath) ){
        return $null
    }

    $Profiles = Get-Content $ProfilePath | ConvertFrom-Json -Depth 100
    return $Profiles.profiles
}