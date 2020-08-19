function Activate-Property
{
    Param(
        [Parameter(Mandatory=$false)]                                [string]   $PropertyName,
        [Parameter(Mandatory=$false)]                                [string]   $PropertyId,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]  [string]   $PropertyVersion,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]  [string] [ValidateSet('Staging', 'Production')]$Network,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   $Note,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [switch]   $UseFastFallback,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]             $NotifyEmails,
        [Parameter(ParameterSetName='postbody', Mandatory=$true)]    [string]   $Body,
        [Parameter(Mandatory=$false)]                                [switch]   $AutoAcknowledgeWarnings,
        [Parameter(Mandatory=$false)]                                [string]   $GroupID,
        [Parameter(Mandatory=$false)]                                [string]   $ContractId,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   [ValidateSet('None', 'Other', 'No_Production_Traffic', 'Emergency')] $NoncomplianceReason,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   $OtherNoncomplianceReason,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   $CustomerEmail,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   $PeerReviewdBy,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [switch]   $UnitTested,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   $TicketID,
        [Parameter(Mandatory=$false)]                                [string]   $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)]                                [string]   $Section = 'papi',
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
        
        $BodyObj = [PSCustomObject]@{
            propertyVersion = $PropertyVersion;
            network = $Network.ToUpper();
            note = $Note;
            useFastFallback = $useFastFallback.ToBool();
            notifyEmails = $NotifyEmails;
        }

        if($NoncomplianceReason)
        {
            $ComplianceRecord = New-Object -TypeName PSCustomObject

            # Only add optional fields if they are present
            if($NoncomplianceReason){
                $ComplianceRecord | Add-Member -MemberType NoteProperty -Name 'noncomplianceReason' = $NoncomplianceReason.ToUpper()
            }
            if($CustomerEmail){
                $ComplianceRecord | Add-Member -MemberType NoteProperty -Name 'customerEmail' = $CustomerEmail
            }
            if($PeerReviewdBy){
                $ComplianceRecord | Add-Member -MemberType NoteProperty -Name 'peerReviewedBy' = $PeerReviewdBy
            }
            if($UnitTested){
                $ComplianceRecord | Add-Member -MemberType NoteProperty -Name 'unitTested' = $UnitTested.ToBool()
            }
            if($TicketID){
                $ComplianceRecord | Add-Member -MemberType NoteProperty -Name 'ticketId' = $TicketID
            }
            if($OtherNoncomplianceReason){
                $ComplianceRecord | Add-Member -MemberType NoteProperty -Name 'otherNoncomplianceReason' = $OtherNoncomplianceReason
            }

            $BodyObj | Add-Member -MemberType NoteProperty -Name 'complianceRecord' -Value $ComplianceRecord
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
        if($_.Exception.Message.Contains("The following activation warnings must be acknowledged.") -and $AutoAcknowledgeWarnings)
        {
            $acknowledgeWarnings = New-Object System.Collections.ArrayList
            $Response = $_.Exception.Message | ConvertFrom-Json
            $Response.Warnings | foreach {
                $acknowledgeWarnings.Add($_.messageId) | Out-Null
            }

            $BodyObj = $Body | ConvertFrom-Json
            $BodyObj | Add-Member -MemberType NoteProperty -Name "acknowledgeWarnings" -Value $acknowledgeWarnings

            $acknowledgedBody = $BodyObj | ConvertTo-Json -Depth 100
            try {
                $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $acknowledgedBody
                return $Result
            }
            catch {
                throw $_.Exception
            }

        }
        else
        {
            throw $_.Exception
        }
        return $_
    }
}

