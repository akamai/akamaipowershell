<#
.SYNOPSIS
EdgeGrid Powershell - Property API
.DESCRIPTION
Activate specific version of Property Manager property
.PARAMETER PropertyName
Name of the property to activate. Either -PropertyName or -PropertyID is required.
.PARAMETER PropertyID
ID of the property to activate. Either -PropertyName or -PropertyID is required.
.PARAMETER PropertyVersion
Version of the property to activate. To activate the latest version use -PropertyVersion 'latest'. REQUIRED
.PARAMETER Network
Network on which to activate. Only 'Staging' and 'Production' are valid. REQUIRED
.PARAMETER Note
Activation note. OPTIONAL
.PARAMETER NotifyEmails
Comma-separated list or PS Array of email addresses to receive activation updates. REQUIRED
.PARAMETER Body
POST body for the activation request. This is instead of specifying PropertyVersion, Network, Note and Notifyemails
.PARAMETER AcknowledgeAllWarnings
Include to automatically acknowledge all warnings thrown by Property Manager validation. OPTIONAL
.PARAMETER GroupId
Group ID, either with grp_ prefix or not. OPTIONAL
.PARAMETER ContractId
Contract ID, either with ctr_ prefix or not. OPTIONAL
.PARAMETER NoncomplianceReason
Internal use only. Part of Akamai peer review process.
.PARAMETER CustomerEmail
Internal use only. Part of Akamai peer review process.
.PARAMETER PeerReviewdBy
Internal use only. Part of Akamai peer review process.
.PARAMETER UnitTested
Internal use only. Part of Akamai peer review process.
.PARAMETER TicketID
Internal use only. Part of Akamai peer review process.
.PARAMETER EdgeRCFile
Path to .edgerc file, defaults to ~/.edgerc. OPTIONAL
.PARAMETER ContractId
.edgerc Section name. Defaults to 'default'. OPTIONAL
.PARAMETER AccountSwitchKey
Account switch key if applying to an account external to yoru API user. Only usable by Akamai staff and partners. OPTIONAL
.EXAMPLE
Activate-Property -PropertyName myproperty -PropertyVersion 1 -Network Staging -NotifyEmails "email@example.com" -AcknowledgeAllWarnings
.LINK
developer.akamai.com
#>


function Activate-Property
{
    Param(
        [Parameter(Mandatory=$false)]                                [string]   $PropertyName,
        [Parameter(Mandatory=$false)]                                [string]   $PropertyId,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]  [string]   $PropertyVersion,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]  [string]   [ValidateSet('Staging', 'Production')] $Network,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   $Note,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [switch]   $UseFastFallback,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]             $NotifyEmails,
        [Parameter(ParameterSetName='postbody', Mandatory=$true)]    [string]   $Body,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [switch]   $AcknowledgeAllWarnings,
        [Parameter(Mandatory=$false)]                                [string]   $GroupID,
        [Parameter(Mandatory=$false)]                                [string]   $ContractId,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   [ValidateSet('NONE', 'OTHER', 'NO_PRODUCTION_TRAFFIC', 'EMERGENCY')] $NoncomplianceReason,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   $OtherNoncomplianceReason,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   $CustomerEmail,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   $PeerReviewdBy,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [switch]   $UnitTested,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   $TicketID,
        [Parameter(Mandatory=$false)]                                [string]   $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)]                                [string]   $Section = 'default',
        [Parameter(Mandatory=$false)]                                [string]   $AccountSwitchKey
    )

    if($PropertyName -eq '' -and $PropertyID -eq ''){
        throw 'Either $PropertyName or $PropertyID must be specified'
    }

    # Find property if user has specified PropertyName
    if($PropertyName){
        try{
            $Property = Find-Property -PropertyName $PropertyName -latest -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            $PropertyID = $Property.propertyId
            if($PropertyID -eq ''){
                throw "Property '$PropertyName' not found"
            }
        }
        catch{
            throw $_.Exception
        }
    }

    if($PropertyVersion.ToLower() -eq "latest"){
        try{
            if($PropertyName){
                $PropertyVersion = $Property.propertyVersion
            }
            else{
                $Property = Get-Property -PropertyId $PropertyID -GroupID $GroupID -ContractId $ContractId -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
                $PropertyVersion = $Property.latestVersion
            }
        }
        catch{
            throw $_.Exception
        }
    }

    if($PSCmdlet.ParameterSetName -eq 'attributes')
    {
        # Convert NotifyEmails to array if required
        if($NotifyEmails.GetType().Name -eq "String"){
            $NotifyEmails = $NotifyEmails -split ","
        }

        if($NoncomplianceReason -eq 'NONE' -and $Network -eq 'Production'){
            if($CustomerEmail -eq '' -or $PeerReviewdBy -eq '' -or $UnitTested -eq $false){
                throw "You must supply the following when NonComplianceReason is 'NONE': CustomerEmail, PeerReviewedBy & UnitTested"
            }
        }
        
        $BodyObj = @{
            propertyVersion = $PropertyVersion;
            network = $Network.ToUpper();
            note = $Note;
            useFastFallback = $useFastFallback.ToBool();
            notifyEmails = $NotifyEmails;
        }

        if($AcknowledgeAllWarnings){
            $BodyObj['acknowledgeAllWarnings'] = $true
        }

        # Only add optional fields if they are present

        $ComplianceRecord = @{}
        if($NoncomplianceReason){
            $ComplianceRecord['noncomplianceReason'] = $NoncomplianceReason
        }
        if($CustomerEmail){
            $ComplianceRecord['customerEmail'] = $CustomerEmail
        }
        if($PeerReviewdBy){
            $ComplianceRecord['peerReviewedBy'] = $PeerReviewdBy
        }
        if($UnitTested){
            $ComplianceRecord['unitTested'] = $UnitTested.ToBool()
        }
        if($TicketID){
            $ComplianceRecord['ticketId'] = $TicketID
        }
        if($OtherNoncomplianceReason){
            $ComplianceRecord['otherNoncomplianceReason'] = $OtherNoncomplianceReason
        }

        # Only add compliance record to body if not empty
        if($ComplianceRecord.count -gt 0){
            $BodyObj['complianceRecord'] =  $ComplianceRecord
        }

        $Body = $BodyObj | ConvertTo-Json -Depth 100
    }

    $Path = "/papi/v1/properties/$PropertyId/activations?contractId=$ContractId&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"
    
    try
    {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $Body
        return $Result
    }
    catch
    {
        throw $_.Exception
    }
}

