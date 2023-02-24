function Update-EdgeKVNamespace
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $NamespaceID,
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edgekv/v1/auth/namespaces/$NamespaceID"

    $BodyObj = @{
        groupId = $GroupID
    }
    $Body = $BodyObj | ConvertTo-Json 

    try {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
