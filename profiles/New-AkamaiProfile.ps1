<#
.SYNOPSIS
EdgeGrid Powershell
.DESCRIPTION
Create new Akamai profile
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
New-AkamaiProfile -Name "myprofile" -GroupID 12345 -ContractID A-B12CD34 -EdgeRCFile ~/customer.edgerc -Section papi -AccountSwitchKey 1-23AB12:1-2RBL
.LINK
developer.akamai.com
#>
function New-AkamaiProfile
{
    param(
        [Parameter(Mandatory=$true)]  [String] $Name,
        [Parameter(Mandatory=$false)] [String] $GroupID,
        [Parameter(Mandatory=$false)] [String] $ContractId,
        [Parameter(Mandatory=$false)] [String] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [String] $Section,
        [Parameter(Mandatory=$false)] [String] $AccountSwitchKey,
        [Parameter(Mandatory=$false)] [String] $ProfilePath = '~/.akamai-cli/akamaipowershell.json'
    )

    $ProfileDir = $ProfilePath.Substring(0,$ProfilePath.LastIndexOf("/"))
    if(! (Test-Path $ProfileDir) ){
        Write-Debug "Creating directory $ProfileDir"
        New-Item -ItemType Directory -Path $ProfileDir | Out-Null
    }

    if(! (Test-Path $ProfilePath) ){
        Write-Debug "Profiles file $ProfilePath does not exist. Creating new Profiles object"
        $Profiles = [PSCustomObject] @{
            ActiveProfile = ''
            Profiles = @()
        }
    }
    else{
        $Profiles = Get-Content $ProfilePath | ConvertFrom-Json -Depth 100
    }

    $ExistingProfile = $Profiles.profiles | Where {$_.Name -eq $Name}
    if($null -ne $ExistingProfile){
        throw "Profile $Name already exists in $ProfilePath"
    }

    $NewProfile = [PSCustomObject] @{
        Name = $Name
        GroupID = $GroupID
        ContractID = $ContractID
        EdgeRCFile = $EdgeRCFile
        Section = $Section
        AccountSwitchKey = $AccountSwitchKey
    }

    $Profiles.Profiles += $NewProfile
    Write-Debug "Updating profile file $ProfilePath"
    $Profiles | ConvertTo-Json -Depth 100 | Out-File $ProfilePath -Force
}