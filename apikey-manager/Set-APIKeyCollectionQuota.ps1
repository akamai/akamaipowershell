function Set-APIKeyCollectionACL
{
    Param(
        [Parameter(Mandatory=$true)] [string] $CollectionID,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)] [string] $Quota,
        [Parameter(Mandatory=$true,ParameterSetName='body',ValueFromPipeline=$true)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin {}

    process {
        if($Quota){
            $Body = ConvertTo-Json $Quota -Depth 100
        }

        $Path = "/apikey-manager-api/v1/collections/$CollectionID/quota?accountSwitchKey=$AccountSwitchKey"

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