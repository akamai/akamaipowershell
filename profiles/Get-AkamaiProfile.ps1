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
Get-AkamaiProfile -Name myprofile
.LINK
developer.akamai.com
#>
function Get-AkamaiProfile
{
    param(
        [Parameter(Mandatory=$true)]  [String] $Name,
        [Parameter(Mandatory=$false)] [String] $ProfilePath = '~/.akamai-cli/akamaipowershell.json'
    )

    if(! (Test-Path $ProfilePath) ){
        return $null
    }

    $Profiles = Get-Content $ProfilePath | ConvertFrom-Json -Depth 100
    return $Profiles.profiles | where {$_.Name -eq $Name}
}