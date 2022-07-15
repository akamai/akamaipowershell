function Set-APIKey
{
    Param(
        [Parameter(Mandatory=$true)] [string] $KeyID,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)] [string] $Key,
        [Parameter(Mandatory=$true,ParameterSetName='body',ValueFromPipeline=$true)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin {}

    process {
        if($Key){
            $Body = ConvertTo-Json $Key -Depth 100
        }

        $Path = "/apikey-manager-api/v1/keys/$KeyID`?accountSwitchKey=$AccountSwitchKey"

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_ 
        }
    }

    end {}

}