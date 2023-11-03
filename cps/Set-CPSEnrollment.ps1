function Set-CPSEnrollment
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $EnrollmentID,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)] [System.Object] $Enrollment,
        [Parameter(Mandatory=$true,ParameterSetName='file')]  [string] $InputFile,
        [Parameter(Mandatory=$true,ParameterSetName='body')]  [string] $Body,
        [Parameter(Mandatory=$false)] [switch] $AllowCancelPendingChanges,
        [Parameter(Mandatory=$false)] [switch] $AllowStagingBypass,
        [Parameter(Mandatory=$false)] [string] $DeployNotAfter,
        [Parameter(Mandatory=$false)] [string] $DeployNotBefore,
        [Parameter(Mandatory=$false)] [switch] $ForceRenewal,
        [Parameter(Mandatory=$false)] [switch] $RenewalDateCheckOverride,
        [Parameter(Mandatory=$false)] [switch] $AllowMissingCertificateAddition,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{
        # nullify false switches
        $AllowCancelPendingChangesString = $AllowCancelPendingChanges.IsPresent.ToString().ToLower()
        if(!$AllowCancelPendingChanges){ $AllowCancelPendingChangesString = '' }

        $AllowStagingBypassString = $AllowStagingBypass.IsPresent.ToString().ToLower()
        if(!$AllowStagingBypass){ $AllowStagingBypassString = '' }

        $ForceRenewalString = $ForceRenewal.IsPresent.ToString().ToLower()
        if(!$ForceRenewal){ $ForceRenewalString = '' }

        $RenewalDateCheckOverrideString = $RenewalDateCheckOverride.IsPresent.ToString().ToLower()
        if(!$RenewalDateCheckOverride){ $RenewalDateCheckOverrideString = '' }

        $AllowMissingCertificateAdditionString = $AllowMissingCertificateAddition.IsPresent.ToString().ToLower()
        if(!$AllowMissingCertificateAddition){ $AllowMissingCertificateAdditionString = '' }

        $DateMatch = '[\d]{4}-[\d]{2}-[\d]{2}'
        if(($DeployNotAfter -or $DeployNotBefore) -and ($DeployNotAfter -notmatch $DateMatch -or $DeployNotBefore -notmatch $DateMatch)){
            throw "ERROR: DeployNotAfter & DeployNotBefore must be in the format 'YYYY-MM-DD'"
        }

        $Path = "/cps/v2/enrollments/$EnrollmentID`?allow-cancel-pending-changes=$AllowCancelPendingChangesString&allow-staging-bypass=$AllowStagingBypassString&force-renewal=$ForceRenewalString&renewal-date-check-override=$RenewalDateCheckOverrideString&allow-missing-certificate-addition=$AllowMissingCertificateAdditionString"
        
        $AdditionalHeaders = @{
            'accept' = 'application/vnd.akamai.cps.enrollment-status.v1+json'
            'content-type' = 'application/vnd.akamai.cps.enrollment.v11+json'
        }
    }

    # Must use Process block as using ValueFromPipeline
    process {
        if($InputFile){
            if(!(Test-Path $InputFile)){
                throw "Input file $Inputfile does not exist"
            }
            $Body = Get-Content $InputFile -Raw
        }
        elseif($Enrollment){
            $Body = $Enrollment | ConvertTo-Json -Depth 100
        }

        # Check body length
        if($Body.length -eq 0 -or $Body -eq 'null'){
            # if ConvertTo-Json gets a $null object, it converts it to a string that is literally 'null'
            throw 'Request body or input object is invalid. Please check'
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            return $Result
        }
        catch {
            throw $_
        }
    }

    end{}
}
