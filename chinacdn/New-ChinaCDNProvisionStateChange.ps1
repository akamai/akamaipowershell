function New-ChinaCDNProvisionStateChange
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Hostname,
        [Parameter(Mandatory=$false)] [switch] $ForceDeprovision,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)]  [object] $Change,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline')]  [object] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/chinacdn/v1/property-hostnames/$Hostname/provision-state-changes/$ChangeID`?accountSwitchKey=$AccountSwitchKey"

        $AdditionalHeaders = @{
            Accept = 'application/vnd.akamai.chinacdn.provision-state-change.v1+json'
        }

        if($Change){
            $Body = $Change | ConvertTo-Json -Depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -AdditionalHeaders $AdditionalHeaders -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_.Exception 
        }
    }

    end{}

    
}