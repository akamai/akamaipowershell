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
Set-ActiveAkamaiProfile -None
.LINK
developer.akamai.com
#>
function Set-ActiveAkamaiProfile
{
    param(
        [Parameter(Mandatory=$false)] [String] $Name,
        [Parameter(Mandatory=$false)] [Switch] $None,
        [Parameter(Mandatory=$false)] [String] $ProfilePath = '~/.akamai-cli/akamaipowershell.json'
    )

    if(! (Test-Path $ProfilePath) ){
        throw "$ProfilePath does not exist"
    }

    $Profiles = Get-Content $ProfilePath | ConvertFrom-Json -Depth 100

    if($None){
        $Profiles.ActiveProfile = $null
    }
    else{
        $ExistingProfile = $Profiles.profiles | where {$_.Name -eq $Name}

        if($null -eq $ExistingProfile){
            throw "Profile $Name does not exist in $ProfilePath"
        }

        Write-Debug "Setting $Name as active profile"
        $Profiles.ActiveProfile = $Name

        Write-Debug "Updating profiles file $ProfilePath"
        $Profiles | ConvertTo-Json -Depth 100 | Out-File $ProfilePath -Force
    }
}