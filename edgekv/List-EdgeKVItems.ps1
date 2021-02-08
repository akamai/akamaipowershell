function List-EdgeKVItems
{
    Param(
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('STAGING','PRODUCTION')] $Network,
        [Parameter(Mandatory=$true)]  [string] $NamespaceID,
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edgekv/v1/networks/$Network/namespaces/$NamespaceID/groups/$GroupID`?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}