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
function Remove-AkamaiProfile
{
    param(
        [Parameter(Mandatory=$true)]  [String] $Name,
        [Parameter(Mandatory=$false)] [String] $ProfilePath = '~/.akamai-cli/akamaipowershell.json'
    )

    if(! (Test-Path $ProfilePath) ){
        return $null
    }

    $Profiles = Get-Content $ProfilePath | ConvertFrom-Json -Depth 100
    $ExistingProfile = $Profiles.profiles | where {$_.Name -eq $Name}
    if($null -eq $ExistingProfile){
        throw "Profile $Name does not exist in $ProfilePath"
    }

    $Profiles.profiles = $Profiles.profiles | where {$_.Name -ne $Name}
    if($null -eq $Profiles.profiles){
        Write-Debug "No profiles remaining. Replacing profiles with empty array"
        $Profiles.profiles = @()
    }
    
    Write-Debug "Updating profiles file $ProfilePath"
    $Profiles | ConvertTo-Json -Depth 100 | Out-File $ProfilePath -Force
}