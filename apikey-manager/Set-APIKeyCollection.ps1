function Set-APIKeyCollection
{
    [CmdletBinding(DefaultParameterSetName = 'body')]
    Param(
        [Parameter(Mandatory=$true)]  [string] $CollectionID,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)] [Object] $Collection,
        [Parameter(Mandatory=$true,ParameterSetName='body')] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}
    
    process{
        if($Collection){
            $Body = ConvertTo-Json -Depth 100 $Collection 
        }

        $Path = "/apikey-manager-api/v1/collections/$CollectionID`?accountSwitchKey=$AccountSwitchKey"

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_ 
        }
    }

    end{}
}