function Set-CPSEnrollment
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $EnrollmentID,
        [Parameter(Mandatory=$false, ValueFromPipeline)] [System.Object] $Enrollment,
        [Parameter(Mandatory=$false)] [string] $InputFile,
        [Parameter(Mandatory=$false)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Must use Process block as using ValueFromPipeline
    process {
        $Path = "/cps/v2/enrollments/$EnrollmentID`?accountSwitchKey=$AccountSwitchKey"
        $AdditionalHeaders = @{
            'accept' = 'application/vnd.akamai.cps.enrollment-status.v1+json'
            'content-type' = 'application/vnd.akamai.cps.enrollment.v11+json'
        }

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
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_.Exception
        }
    }  
}