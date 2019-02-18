#************************************************************************
#
#	Name: AkamaiPowershell.psm1
#	Author: S Macleod
#	Purpose: Standard methods to interact with Luna API
#	Date: 21/11/18
#	Version: 3 - Moved to .edgerc support
#
#************************************************************************

Import-Module $PSScriptRoot\Private\Invoke-AkamaiOPEN.psm1 -Force


function Get-AKCredentialsFromRC
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $ConfigFile = '~\.edgerc'
    )

    if(!(Test-Path $ConfigFile))
    {
        Write-Host -ForegroundColor Red "ConfigFile $ConfigFile not found"
        return $false
    }

    $Config = Get-Content $ConfigFile
    if("[$Section]" -notin $Config)
    {
        Write-Host -ForegroundColor Red "Config section [$Section] not found in $ConfigFile"
        return $false
    }

    $Credentials = New-Object -TypeName PSCustomObject

    $ConfigIndex = [array]::indexof($Config,"[$Section]")
    $SectionArray = $Config[$ConfigIndex..($ConfigIndex + 4)]
    $SectionArray | foreach {
        if($_.Contains("="))
        {
            $AttrName = $_.Substring(0, $_.IndexOf("=")).Trim()
            $AttrValue = $_.Substring($_.IndexOf("=") + 1).Trim()
            $Credentials | Add-Member -MemberType NoteProperty -Name $AttrName -Value $AttrValue
        }
    }

    return $Credentials
}

function Get-PapiAccountID
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/groups"
    $groups = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    $AccID = $Groups.accountId.Replace("act_","")
    
    return $AccID          
}

function List-PapiContracts
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/contracts"
    $Contracts = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
   
    return $Contracts.Contracts.items       
}

function Get-PapiGroups
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $Detail,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/groups"
    $groups = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    $returnGroup = $groups.groups.items
    
    if($Detail)
    {
        $returnGroup = $groups
    }
    
    return $returnGroup          
}

function Get-PapiGroupDetails
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Group,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/groups"
    $groups = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    $returnGroup = $groups.groups.items | where {$_.groupName -eq $group} 
    return $returnGroup          
}

function Get-PapiProducts
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/products/?contractId=$ContractId"
    $Products = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL

    return $Products
}

function Get-PapiProperties
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/properties?contractId=$ContractId&groupId=$GroupID"
    $Properties = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    $returnProperties = $Properties.properties.items
    return $returnProperties     
}

function Get-PapiPropertyInfo
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$true)]  [string] $PropertyName,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/properties?contractId=$ContractId&groupId=$GroupID"
    $Properties = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    $returnProperties = $Properties.properties.items | where {$_.propertyName -eq $PropertyName}
    return $returnProperties     
}

function Get-PapiPropertyVersions
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/properties/$PropertyId/versions/?contractId=$ContractId&groupId=$GroupID"
    $PropertyVersions = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    $returnVersions = $PropertyVersions.versions.items 
    return $returnVersions     
}

function Get-PapiLatestVersionOfProperty
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/properties/$PropertyId/versions/latest" #?contractId=$ContractId&groupId=$GroupID"
    $PropertyVersions = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    $returnVersions = $PropertyVersions.versions.items 
    #return $returnVersions
    return $PropertyVersions
}

function Get-PapiSpecificVersionOfProperty
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $Version,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/properties/$PropertyId/versions/$Version`?contractId=$ContractId&groupId=$GroupID"
    $PropertyVersions = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    $returnVersions = $PropertyVersions.versions.items 
    return $returnVersions
}

function Get-PapiPropertyVersionXML
{
    Param(
      [Parameter(Mandatory=$true)]  [string] $GroupID,
      [Parameter(Mandatory=$true)]  [string] $ContractId,
      [Parameter(Mandatory=$true)]  [string] $PropertyId,
      [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
      [Parameter(Mandatory=$false)] [switch] $XML,
      [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/properties/$PropertyId/versions/$PropertyVersion`?contractId=$ContractId&groupId=$GroupID"
    if($XML)
    {
        $returnVersionXML = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -XML
    }
    else
    {
        $returnVersionXML = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    }
    return $returnVersionXML  
}

function Get-PapiAllProperties
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    $Properties = @()
    $Groups = Get-PapiGroups -Section $Section
    foreach($Group in $Groups)
    {
        if($Group.contractIds.length -gt 0)
        {
            $Properties += Get-PapiProperties -Section $Section -GroupID $Group.groupID -ContractId $group.ContractIDs[0]
        }
    }

    return $Properties
}

function Get-PapiPropertyHosts
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $versionNo,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/properties/$PropertyId/versions/$versionNo/hostnames/?contractId=$ContractId&groupId=$GroupID"
    $Hostnames = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    $returnHostnamesObject = $Hostnames.hostnames.items
    return $returnHostnamesObject
}

function Get-PapiEdgeHostnameObj
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/edgehostnames?contractId=$ContractId&groupId=$GroupID"
    $edgehostnames = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    $AllEdgeObjects = $edgehostnames.edgeHostnames.items
    return $AllEdgeObjects
}

function Create-PapiNewVersion
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [int]    $ProdVersionNo,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/properties/$PropertyId/versions/?contractId=$ContractId&groupId=$GroupID"
    $PostObject = @{"createFromVersion"=$ProdVersionNo}
    $Body = $PostObject | Convertto-json
    $NewVersion = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $Body
    write-host "New Version Created"
    return $NewVersion
}

function Push-PapiHostNamesToAkamai
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [int]    $LatestVersionNo,
        [Parameter(Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/properties/$PropertyId/versions/$LatestVersionNo/hostnames/?contractId=$ContractId&groupId=$GroupID"
    $Result = Invoke-AkamaiOPEN -Method PUT -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $Body
    return $Result
}

function Get-PapiPropertyRuleTree
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/properties/$PropertyId/versions/$PropertyVersion/rules/?contractId=$ContractId&groupId=$GroupID"
    $PropertyRuleTree = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    #$returnVersions = $PropertyVersions.versions.items 
    return $PropertyRuleTree     
}

Function Set-PapiPropertyRuleTree
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/properties/$PropertyId/versions/$PropertyVersion/rules/?contractId=$ContractId&groupId=$GroupID"
    try
    {
        $PropertyRuleTree = Invoke-AkamaiOPEN -Method PUT -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $Body
    }
    catch
    {
        $returnobject = $_
        if($returnobject.Exception -Match "The operation has timed out")
        {
            write-host "The operation to push changes timed out but changes were pushed. Ignoring"
        }
        else
        {
            write-host "Error on pushing changes:"
            write-host "$_"
        }
    }
}

function Activate-PapiProperty #same as Push-VersionLive, just different name
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/properties/$PropertyId/activations/?contractId=$ContractId&groupId=$GroupID"
    try
    {
        $PushVersionLive = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $Body
        $returnobject = "Success"
    }
    catch
    {
        $returnobject = $_
        return $returnobject
    }
}

function Push-PapiVersionLive
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/properties/$PropertyId/activations/?contractId=$ContractId&groupId=$GroupID"
    try
    {
        $PushVersionLive = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $Body
        $returnobject = "Success"
    }
    catch
    {
        $returnobject = $_
        return $returnobject
    }
}

function Get-PapiActivationData
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  $VersionNo,
        [Parameter(Mandatory=$true)]  [string] $Network,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/properties/$PropertyId/activations/?contractId=$ContractId&groupId=$GroupID"
    $ListActivations = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    $returnObject = $ListActivations.activations.items | where {$_.propertyVersion -eq $VersionNo -and $_.network -eq $Network}
    return $returnObject
}

function Get-PapiActivation
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $ActivationID,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/properties/$PropertyId/activations/$ActivationID`?contractId=$ContractId&groupId=$GroupID"
    $Activation = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Activation
}

function List-PapiCPCodesForGroup
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$true)]  [string] $GroupId,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/cpcodes?contractId=$ContractID&groupId=$GroupID"
    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result.cpcodes.items
}

function Get-PapiCPCode
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $CPCode,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/cpcodes/$cpcodeId"
    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

# SiteShield

function List-SiteShieldMaps
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'site-shield'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/siteshield/v1/maps/"
    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result.SiteShieldMaps
}

function Get-SiteShieldMapByID
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $SiteShieldID,
        [Parameter(Mandatory=$false)] [string] $Section = 'site-shield'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/siteshield/v1/maps/" + $SiteShieldID
    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

function Acknowledge-SiteShieldMapByID
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $SiteShieldID,
        [Parameter(Mandatory=$false)] [string] $Section = 'site-shield'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/siteshield/v1/maps/$SiteShieldID/acknowledge"
    $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

# Cloudlets

function List-Cloudlets
{
    Param(
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $Section = 'cloudlets'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cloudlets/api/v2/cloudlet-info"
    if($GroupID)
    {
        $ReqURL = $ReqURL + "?gid=$GroupID"
    }
    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

function Get-Cloudlet
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $CloudletID,
        [Parameter(Mandatory=$false)] [string] $Section = 'cloudlets'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cloudlets/api/v2/cloudlet-info/$CloudletID"
    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

function List-CloudletPolicies
{
    Param(
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [switch] $IncludeDeleted,
        [Parameter(Mandatory=$false)] [string] $CloudletID,
        [Parameter(Mandatory=$false)] [string] $ClonePolicyID,
        [Parameter(Mandatory=$false)] [string] $Version,
        [Parameter(Mandatory=$false)] [string] $Section = 'cloudlets'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cloudlets/api/v2/policies"

    if($psboundparameters.Count -gt 1) { $ReqURL += "?" }
    if($GroupID)                       { $ReqURL += "&gid=$GroupID" }
    if($IncludeDeleted)                { $ReqURL += "&includedeleted=true" }
    if($CloudletID)                    { $ReqURL += "&dc=$DC" }
    if($ClonePolicyID)                 { $ReqURL += "&clonepolicyid=$ClonePolicyID" }
    if($Version)                       { $ReqURL += "&version=$Version" }


    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

function Get-CloudletPolicy
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$false)] [string] $Section = 'cloudlets'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cloudlets/api/v2/policies/$PolicyID"
    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

function List-CloudletPolicyVersions
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$false)] [string] $CloneVersion,
        [Parameter(Mandatory=$false)] [switch] $IncludeRules,
        [Parameter(Mandatory=$false)] [string] $MatchRuleFormat,
        [Parameter(Mandatory=$false)] [string] $Section = 'cloudlets'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cloudlets/api/v2/policies/$PolicyID/versions"

    if($psboundparameters.Count -gt 2) { $ReqURL += "?" }
    if($CloneVersion)                  { $ReqURL += "&cloneVersion=$CloneVersion" }
    if($IncludeRules)                  { $ReqURL += "&includeRules=true" }
    if($MatchRuleFormat)               { $ReqURL += "&matchRuleFormat=$MatchRuleFormat" }

    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

function Get-CloudletPolicyVersion
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$true)]  [string] $Version,
        [Parameter(Mandatory=$false)] [string] $MatchRuleFormat,
        [Parameter(Mandatory=$false)] [switch] $OmitRules,
        [Parameter(Mandatory=$false)] [string] $Section = 'cloudlets'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cloudlets/api/v2/policies/$PolicyID/versions/$Version"

    if($psboundparameters.Count -gt 3) { $ReqURL += "?" }
    if($MatchRuleFormat)               { $ReqURL += "&matchRuleFormat=$MatchRuleFormat" }
    if($OmitRules)                     { $ReqURL += "&omitRules=true" }

    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}


function List-CloudletGroups
{
    Param(
        [Parameter(Mandatory=$false)] $Section = 'cloudlets'
    )
    
    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cloudlets/api/v2/group-info"

    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

function Get-CloudletGroup
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $Section = 'cloudlets'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cloudlets/api/v2/group-info/$GroupID"

    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

function Create-CloudletPolicy
{
    Param(
        [Parameter(Mandatory=$true) ] [string] $Name,
        [Parameter(Mandatory=$false)] [string] $Description,
        [Parameter(Mandatory=$true) ] [int]    $GroupID,
        [Parameter(Mandatory=$false)] [switch] $IncludeDeleted,
        [Parameter(Mandatory=$true) ] [int]    $CloudletID,
        [Parameter(Mandatory=$false)] [string] $ClonePolicyID,
        [Parameter(Mandatory=$false)] [string] $Version,
        [Parameter(Mandatory=$false)] [string] $Section = 'cloudlets'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cloudlets/api/v2/policies"

    if($psboundparameters.Count -gt 1) { $ReqURL += "?" }
    if($GroupID)                       { $ReqURL += "&gid=$GroupID" }
    if($IncludeDeleted)                { $ReqURL += "&includedeleted=true" }
    if($CloudletID)                    { $ReqURL += "&dc=$DC" }
    if($ClonePolicyID)                 { $ReqURL += "&clonepolicyid=$ClonePolicyID" }
    if($Version)                       { $ReqURL += "&version=$Version" }


    $Post = @{ name = $Name; cloudletId = $CloudletID; groupId = $GroupID; description = $Description }
    $PostJson = ConvertTo-Json $Post -Depth 10

    $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $PostJson
    return $Result
}

function Create-CloudletPolicyVersion
{
    Param(
        [Parameter(Mandatory=$true) ] [string] $PolicyID,
        [Parameter(Mandatory=$false)] [string] $Description,
        [Parameter(Mandatory=$false)] [object[]] $MatchRules,
        [Parameter(Mandatory=$false)] [string] $CloneVersion,
        [Parameter(Mandatory=$false)] [switch] $IncludeRules,
        [Parameter(Mandatory=$false)] [string] $MatchRuleFormat = '1.0',
        [Parameter(Mandatory=$false)] [string] $Section = 'cloudlets'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cloudlets/api/v2/policies/$PolicyID/versions"

    if($psboundparameters.Count -gt 2) { $ReqURL += "?" }
    if($CloneVersion)                  { $ReqURL += "&cloneVersion=$CloneVersion" }
    if($IncludeRules)                  { $ReqURL += "&includeRules=true" }
    if($MatchRuleFormat)               { $ReqURL += "&matchRuleFormat=$MatchRuleFormat" }

    ## Remove unneeded member

    $MatchRules | foreach {
        $_.PsObject.Members.Remove('matchURL')
        $_.PsObject.Members.Remove('location')
    }
    
    $Post = @{ description = $Description; matchRuleFormat = $MatchRuleFormat; matchRules = $MatchRules }
    $PostJson = ConvertTo-Json $Post -Depth 10

    $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $PostJson
    return $Result
}

function Activate-CloudletPolicyVersion
{
    Param(
        [Parameter(Mandatory=$true)]   [string] $PolicyID,
        [Parameter(Mandatory=$true)]   [string] $Version,
        [Parameter(Mandatory=$false)]  [string] $Network = 'production',
        [Parameter(Mandatory=$false)]  [string] $Section = 'cloudlets'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cloudlets/api/v2/policies/$PolicyID/versions/$Version/activations"
    $Body = @{ network = $Network }
    $JsonBody = $Body | ConvertTo-Json -Depth 100
    $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $JsonBody
    return $Result
}

function Remove-CloudletPolicy
{
    Param(
        [Parameter(Mandatory=$true)]  [int] $PolicyID,
        [Parameter(Mandatory=$false)] [string] $Section = 'cloudlets'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cloudlets/api/v2/policies/$PolicyID"

    $Result = Invoke-AkamaiOPEN -Method DELETE -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

# User Admin

function List-UserAdminUsers
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $AccountID,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/user-admin/v1/accounts/$AccountID/users"

    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

function Get-UserAdminUser
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ContactID,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/user-admin/v1/users/$ContactID"

    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

function Delete-UserAdminUser
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ContactID,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/user-admin/v1/users/$ContactID"

    $Result = Invoke-AkamaiOPEN -Method DELETE -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

### Cache Control Utility

function Invalidate-CCUCacheByURL
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $URL,
        [Parameter(Mandatory=$false)] [string] $Network = 'production',
        [Parameter(Mandatory=$false)] [string] $Section = 'ccu'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $PostBody = @{ objects = @("$URL") }
    $PostJson = $PostBody | ConvertTo-Json -Depth 100
    $ReqURL = "https://" + $Credentials.host + "/ccu/v3/invalidate/url/$Network"

    Write-host $PostJson
    Write-Host $ReqURL

    $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $PostJson
    return $Result
}

function Invalidate-CCUCacheByCPCode
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $CPCode,
        [Parameter(Mandatory=$false)] [string] $Network = 'production',
        [Parameter(Mandatory=$false)] [string] $Section = 'ccu'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $PostBody = @{ objects = @("$CPCode") }
    $PostJson = $PostBody | ConvertTo-Json -Depth 100
    $ReqURL = "https://" + $Credentials.host + "/ccu/v3/invalidate/cpcode/$Network"

    $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $PostJson
    return $Result
}

function Delete-CCUCacheByURL
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $URL,
        [Parameter(Mandatory=$false)] [string] $Network = 'production',
        [Parameter(Mandatory=$false)] [string] $Section = 'ccu'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $PostBody = @{ objects = @("$URL") }
    $PostJson = $PostBody | ConvertTo-Json -Depth 100
    $ReqURL = "https://" + $Credentials.host + "/ccu/v3/delete/url/$Network"

    $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $PostJson
    return $Result
}

function Delete-CCUCacheByCPCode
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $CPCode,
        [Parameter(Mandatory=$false)] [string] $Network = 'production',
        [Parameter(Mandatory=$false)] [string] $Section = 'ccu'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $PostBody = @{ objects = @("$CPCode") }
    $PostJson = $PostBody | ConvertTo-Json -Depth 100
    $ReqURL = "https://" + $Credentials.host + "/ccu/v3/delete/cpcode/$Network"
    $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $PostJson
    return $Result
}

# LDS

function Get-LDSLogSources
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'default'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/lds-api/v3/log-sources"
    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

function Get-LDSLogSource
{
    Param(
        [Parameter(Mandatory=$false)] [string] $logSourceType = "cpcode-products",
        [Parameter(Mandatory=$true)]  [string] $logSourceId,
        [Parameter(Mandatory=$false)] [string] $Section = 'default'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/lds-api/v3/log-sources/$logSourceType/$logSourceId"
    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

function List-LDSLogConfigurationsByType
{
    Param(
        [Parameter(Mandatory=$false)] [string] $logSourceType = "cpcode-products",
        [Parameter(Mandatory=$false)] [string] $Section = 'default'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/lds-api/v3/log-sources/$logSourceType/log-configurations"
    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

function List-LDSLogConfigurationForID
{
    Param(
        [Parameter(Mandatory=$false)] [string] $logSourceType = "cpcode-products",
        [Parameter(Mandatory=$true)]  [string] $logSourceId,
        [Parameter(Mandatory=$false)] [string] $Section = 'default'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/lds-api/v3/log-sources/$logSourceType/$logSourceId/log-configurations"
    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

function Get-LDSLogConfiguration
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $logConfigurationId,
        [Parameter(Mandatory=$false)] [string] $Section = 'default'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/lds-api/v3/log-configurations/$logConfigurationId"
    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}


function Update-LDSLogConfiguration
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $logConfigurationId,
        [Parameter(Mandatory=$true)]  [string] $NewConfigJSON,
        [Parameter(Mandatory=$false)] [string] $Section = 'default'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/lds-api/v3/log-configurations/$logConfigurationId"
    $Result = Invoke-AkamaiOPEN -Method PUT -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $NewConfigJSON
    return $Result
}

function List-LDSFTPCPCodes
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'default'
    )
    
    $Results = @()
    $LogConfigurations = Get-LDSLogSources -Section $Section
    foreach($CP in $LogConfigurations)
    {
        $Config = List-LDSLogConfigurationForID -Section $Section -logSourceID $CP.id
        if($Config -ne $null)
        {
            $Results += $Config
        }
    }

    return $Results
}

function List-LDSLogFormatsByType
{
    Param(
        [Parameter(Mandatory=$false)] [string] $logSourceType = "cpcode-products",
        [Parameter(Mandatory=$false)] [string] $Section = 'default'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }
    
    $ReqURL = "https://" + $Credentials.host + "/lds-api/v3/log-sources/$logSourceType/log-formats"
    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

function Find-LDSLogformatIDorName
{
    Param(
        [Parameter(Mandatory=$false)] [int] $LogFormatID,
        [Parameter(Mandatory=$false)] [string] $LogFormatName,
        [Parameter(Mandatory=$false)] [string] $Section = 'default'
    )

    $LogFormats = List-LDSLogFormatsByType -Section $Section

    if($LogFormatID)
    {
        $Format = $LogFormats | where {$_.id -eq $LogFormatID}
        return $Format.value
    }

    elseif($LogFormatName)
    {
        Write-host "Name"
        $Format = $LogFormats | where {$_.value -eq $LogFormatName}
        return $Format.id
    }
}

### Firewall Rules Manager

function List-FRMServices
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'firewall'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }
    
    $ReqURL = "https://" + $Credentials.host + "/firewall-rules-manager/v1/services"
    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

function Get-FRMService
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ServiceID,
        [Parameter(Mandatory=$false)] [string] $Section = 'firewall'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }
    
    $ReqURL = "https://" + $Credentials.host + "/firewall-rules-manager/v1/services/$ServiceID"
    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

function Get-FRMCidrBlock
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'firewall'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }
    
    $ReqURL = "https://" + $Credentials.host + "/firewall-rules-manager/v1/cidr-blocks"
    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}