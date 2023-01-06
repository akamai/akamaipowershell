function Update-EdgeKVNamespace
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $NamespaceID,
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edgekv/v1/auth/namespaces/$NamespaceID`?accountSwitchKey=$AccountSwitchKey"

    $BodyObj = @{
        groupId = $GroupID
    }
    $Body = $BodyObj | ConvertTo-Json 

    try {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}