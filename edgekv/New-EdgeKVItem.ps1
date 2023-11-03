function New-EdgeKVItem
{
    Param(
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('STAGING','PRODUCTION')] $Network,
        [Parameter(Mandatory=$true)]  [string] $NamespaceID,
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ItemID,
        [Parameter(Mandatory=$true)]  [string] $Value,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edgekv/v1/networks/$Network/namespaces/$NamespaceID/groups/$GroupID/items/$ItemID"

    try {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Value -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
