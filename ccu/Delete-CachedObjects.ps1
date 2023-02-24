function Delete-CachedObjects
{
    Param(
        [Parameter(ParameterSetName='url', Mandatory=$true)]    [string] $URLs,
        [Parameter(ParameterSetName='cpcode', Mandatory=$true)] [string] $CPCodes,
        [Parameter(ParameterSetName='tag', Mandatory=$true)]    [string] $Tags,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('staging', 'production')] $Network = 'production',
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section = 'ccu',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    Write-Host -ForegroundColor Yellow "Warning: This cmdlet is deprecated and will be removed in a future release"

    if($AccountSwitchKey)
    {
        Write-Host -ForegroundColor Yellow "The FastPurge API currently does not support Account Switching. Sorry"
        return
        #
    }

    $Objects = @()
    if($URLs){
        if($URLs.Contains(",")) {
            $URLs = $URLs.Replace(" ","")
            $URLs = $URLs -split ","
        }
        $Objects += $URLs
    }
    if($CPCodes){
        if($CPCodes.Contains(",")) {
            $CPCodes = $CPCodes.Replace(" ","")
            $CPCodes = $CPCodes -split ","
        }
        $Objects += $CPCodes
    }
    if($Tags){
        if($Tags.Contains(",")) {
            $Tags = $Tags.Replace(" ","")
            $Tags = $Tags -split ","
        }
        $Objects += $Tags
    }
    $PostBody = @{ 'objects' = $Objects }
    $PostJson = $PostBody | ConvertTo-Json -Depth 100

    $Path = "/ccu/v3/delete/$($PSCmdlet.ParameterSetName)/$($Network.ToLower())"

    try
    {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey -Body $PostJson
        return $Result
    }
    catch
    {
       throw $_ 
    }
}
