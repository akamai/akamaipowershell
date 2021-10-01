function New-ChinaCDNPropertyHostname
{
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='attributes')]   [string] $Hostname,
        [Parameter(Mandatory=$false,ParameterSetName='attributes')]  [string] $ICPNumberID,
        [Parameter(Mandatory=$false,ParameterSetName='attributes')]  [string] $ServiceCategory,
        [Parameter(Mandatory=$false,ParameterSetName='attributes')]  [string] $Comments,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)]  [object] $PropertyHostname,
        [Parameter(Mandatory=$true,ParameterSetName='body')]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/chinacdn/v1/property-hostnames/$Hostname`?accountSwitchKey=$AccountSwitchKey"

        $AdditionalHeaders = @{
            Accept = 'application/vnd.akamai.chinacdn.property-hostname.v1+json'
            'Content-Type' = 'application/vnd.akamai.chinacdn.property-hostname.v1+json'
        }

        if($PSCmdlet.ParameterSetName -eq 'attributes'){
            $BodyObj = @{
                hostname = $Hostname
            }
            if($ICPNumberID){
                $BodyObj['icpNumberId'] = $ICPNumberID
            }
            if($ServiceCategory){
                $BodyObj['serviceCategory'] = $ServiceCategory
            }
            if($Comments){
                $BodyObj['comments'] = $Comments
            }

            $Body = $BodyObj | ConvertTo-Json -Depth 100
        }
        elseif($PSCmdlet.ParameterSetName -eq 'pipeline'){
            $Body = $PropertyHostname | ConvertTo-Json -Depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_.Exception 
        }
    }

    end{}
}