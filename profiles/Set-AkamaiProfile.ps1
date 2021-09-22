<#
.SYNOPSIS
EdgeGrid Powershell
.DESCRIPTION
Update Akamai Profile
.PARAMETER Name
Name for the profile
.PARAMETER GroupID
Group ID
.PARAMETER ContractId
Contract ID
.PARAMETER EdgeRCFile
On-disk location of EdgeRC file
.PARAMETER Section
.edgerc section title
.PARAMETER AccountSwitchKey
Account Switch Key
.PARAMETER ProfilePath
On-disk location of profiles JSON file
.EXAMPLE
Set-AkamaiProfile -Name "myprofile" -GroupID 12345
.LINK
developer.akamai.com
#>
function Set-AkamaiProfile
{
    param(
        [Parameter(Mandatory=$false)] [String] $Name,
        [Parameter(Mandatory=$false)] [String] $GroupID,
        [Parameter(Mandatory=$false)] [String] $ContractId,
        [Parameter(Mandatory=$false)] [String] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [String] $Section,
        [Parameter(Mandatory=$false)] [String] $AccountSwitchKey,
        [Parameter(Mandatory=$false)] [String] $ProfilePath = '~/.akamai-cli/akamaipowershell.json'
    )

    if(! (Test-Path $ProfilePath) ){
        throw "$ProfilePath does not exist"
    }
    else{
        $Profiles = Get-Content $ProfilePath | ConvertFrom-Json -Depth 100
    }

    $ExistingProfile = $Profiles.profiles | Where {$_.Name -eq $Name}
    if($null -eq $ExistingProfile){
        throw "Profile $Name does not exist in $ProfilePath. Use New-AkamaiProfile to create"
    }

    if($Name -ne ''){
        $ExistingProfile.Name = $Name
    }
    if($GroupID -ne ''){
        $ExistingProfile.GroupID = $GroupID
    }
    if($ContractId -ne ''){
        $ExistingProfile.ContractId = $ContractId
    }
    if($EdgeRCFile -ne ''){
        $ExistingProfile.EdgeRCFile = $EdgeRCFile
    }
    if($Section -ne ''){
        $ExistingProfile.Section = $Section
    }
    if($AccountSwitchKey -ne ''){
        $ExistingProfile.AccountSwitchKey = $AccountSwitchKey
    }

    Write-Debug "Updating profile $Name in $ProfilePath"
    $Profiles | ConvertTo-Json -Depth 100 | Out-File $ProfilePath -Force
}