<#
.SYNOPSIS
EdgeGrid Powershell
.DESCRIPTION
Lists profiles stored on disk, either in the default path or a specified one.
.PARAMETER Name
Name of the desired profile
.PARAMETER ProfilePath
On-disk location of profiles JSON file
.EXAMPLE
Set-ActiveAkamaiProfile -Name myprofile
.LINK
developer.akamai.com
#>
function Get-ActiveAkamaiProfile
{
    param(
        [Parameter(Mandatory=$false)] [String] $ProfilePath = '~/.akamai-cli/akamaipowershell.json'
    )

    if(! (Test-Path $ProfilePath) ){
        throw "$ProfilePath does not exist"
    }

    $Profiles = Get-Content $ProfilePath | ConvertFrom-Json -Depth 100
    return $Profiles.profiles | where {$_.Name -eq $Profiles.ActiveProfile}
}