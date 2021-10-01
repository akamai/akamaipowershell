function Set-LDSLogConfiguration
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $logConfigurationId,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)]  [object] $LogConfiguration,
        [Parameter(Mandatory=$true,ParameterSetName='postbody')]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/lds-api/v3/log-configurations/$logConfigurationId`?accountSwitchKey=$AccountSwitchKey"
        if($LogConfiguration){
            $Body = $LogConfiguration | ConvertTo-Json -Depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result 
        }
        catch {
            throw $_.Exception
        }
    }

    end{}
}