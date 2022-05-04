function Set-APIKeyCollectionACL
{
    Param(
        [Parameter(Mandatory=$true)] [string] $CollectionID,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)] [string[]] $ACL,
        [Parameter(Mandatory=$true,ParameterSetName='body',ValueFromPipeline=$true)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin {}

    process {
        if($ACL){
            $Body = $ACL | ConvertTo-Json
        }

        $Path = "/apikey-manager-api/v1/collections/$CollectionID/acl?accountSwitchKey=$AccountSwitchKey"

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_.Exception 
        }
    }

    end {}

}