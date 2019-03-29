function Activate-Property
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PropertyId,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)] [int] $PropertyVersion,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)] [string] [ValidateSet('Staging', 'Production')]$Network,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] $Note,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [switch] $UseFastFallback,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)] [string[]] $NotifyEmails,
        [Parameter(ParameterSetName='postbody', Mandatory=$true)] [string] $Body,
        [Parameter(Mandatory=$false)] [switch] $AutoAcknowledgeWarnings,
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] [ValidateSet('None', 'Other', 'No_Production_Traffic', 'Emergency')] $NoncomplianceReason,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] $OtherNoncomplianceReason,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] $CustomerEmail,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] $PeerReviewdBy,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [switch] $UnitTested,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] $TicketID,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    if($PSCmdlet.ParameterSetName -eq 'attributes')
    {
        $BodyObj = [PSCustomObject]@{
            propertyVersion = $PropertyVersion;
            network = $Network.ToUpper();
            note = $Note;
            useFastFallback = $useFastFallback.ToBool();
            notifyEmails = $NotifyEmails;
        }

        if($NoncomplianceReason)
        {
            $ComplianceRecord = [PSCustomObject]@{
                noncomplianceReason = $NoncomplianceReason.ToUpper()
                customerEmail = $CustomerEmail
                peerReviewedBy = $PeerReviewdBy
                unitTested = $UnitTested.ToBool()
                ticketId = $TicketID
                otherNoncomplianceReason = $OtherNoncomplianceReason
            }

            $BodyObj | Add-Member -MemberType NoteProperty -Name 'complianceRecord' -Value $ComplianceRecord
        }

        $Body = $BodyObj | ConvertTo-Json -Depth 100
    }

    <#
    {
        "propertyVersion": 1,
        "network": "STAGING",
        "note": "Sample activation",
        "useFastFallback": false,
        "notifyEmails": [
            "you@example.com",
            "them@example.com"
        ],
        "acknowledgeWarnings": [
            "msg_baa4560881774a45b5fd25f5b1eab021d7c40b4f"
        ]
    }
    #>

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/properties/$PropertyId/activations/?contractId=$ContractId&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"
    
    try
    {
        $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $Body
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
                $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $acknowledgedBody
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

