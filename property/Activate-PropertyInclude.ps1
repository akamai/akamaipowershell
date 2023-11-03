function Activate-PropertyInclude
{
    Param(
        [Parameter(Mandatory=$false)]                                [string]   $IncludeName,
        [Parameter(Mandatory=$false)]                                [string]   $IncludeID,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]  [string]   $IncludeVersion,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]  [string]   [ValidateSet('Staging', 'Production')] $Network,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   $Note,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [switch]   $UseFastFallback,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]             $NotifyEmails,
        [Parameter(ParameterSetName='postbody', Mandatory=$true)]    [string]   $Body,
        [Parameter(Mandatory=$false)]                                [string]   $GroupID,
        [Parameter(Mandatory=$false)]                                [string]   $ContractId,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   [ValidateSet('NONE', 'OTHER', 'NO_PRODUCTION_TRAFFIC', 'EMERGENCY')] $NoncomplianceReason,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   $OtherNoncomplianceReason,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   $CustomerEmail,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   $PeerReviewedBy,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [switch]   $UnitTested,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   $TicketID,
        [Parameter(Mandatory=$false)]                                [string]   $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)]                                [string]   $Section = 'default',
        [Parameter(Mandatory=$false)]                                [string]   $AccountSwitchKey
    )

    if($PropertyName -eq '' -and $PropertyID -eq ''){
        throw 'Either $PropertyName or $PropertyID must be specified'
    }

    if($IncludeName){
        try{
            $Include = Find-Property -IncludeName $IncludeName -latest -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            if($null -eq $Include){
                throw "Include '$IncludeName' not found"
            }
            $IncludeID = $Include.includeId
        }
        catch{
            throw $_
        }
    }

    if($IncludeVersion.ToLower() -eq "latest"){
        if($IncludeName -eq ''){
            $Include = Find-Property -IncludeName $IncludeName -latest -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        }
        $IncludeVersion = $Include.includeVersion
    }

    if($PSCmdlet.ParameterSetName -eq 'attributes')
    {
        # Convert NotifyEmails to array if required
        if($NotifyEmails.GetType().Name -eq "String"){
            $NotifyEmails = $NotifyEmails -split ","
        }

        if($NoncomplianceReason -eq 'NONE' -and $Network -eq 'Production'){
            if($CustomerEmail -eq '' -or $PeerReviewedBy -eq '' -or $UnitTested -eq $false){
                throw "You must supply the following when NonComplianceReason is 'NONE': CustomerEmail, PeerReviewedBy & UnitTested"
            }
        }
        
        $BodyObj = @{
            includeVersion = $IncludeVersion;
            network = $Network.ToUpper();
            note = $Note;
            useFastFallback = $useFastFallback.ToBool();
            acknowledgeAllWarnings = $true
            notifyEmails = $NotifyEmails
        }

        # Only add optional fields if they are present

        
        
        $ComplianceRecord = @{}
        if($NoncomplianceReason){
            $ComplianceRecord['noncomplianceReason'] = $NoncomplianceReason
        }
        if($CustomerEmail){
            $ComplianceRecord['customerEmail'] = $CustomerEmail
        }
        if($PeerReviewedBy){
            $ComplianceRecord['peerReviewedBy'] = $PeerReviewedBy
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

        $Body = ConvertTo-Json -Depth 100 $BodyObj
    }

    $Path = "/papi/v1/includes/$IncludeID/activations?contractId=$ContractId&groupId=$GroupID"
    
    try
    {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey -Body $Body
        return $Result
    }
    catch
    {
        throw $_
    }
}
