function Invalidate-CachedObjects
{
    Param(
        [Parameter(ParameterSetName='url', Mandatory=$true)]    [string] $URLs,
        [Parameter(ParameterSetName='cpcode', Mandatory=$true)] [string] $CPCodes,
        [Parameter(ParameterSetName='tag', Mandatory=$true)]    [string] $Tags,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('staging', 'production')] $Network = 'production',
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'ccu',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    Write-Host -ForegroundColor Yellow "Warning: This cmdlet is deprecated and will be removed in a future release"

    if($AccountSwitchKey)
    {
        Write-Host -ForegroundColor Yellow "The FastPurge API currently does not support Account Switching. Sorry"
        return
        #?accountSwitchKey=$AccountSwitchKey
    }

    $Objects = @()
    if($URLs){
        if($URLs.Contains(",")) {
            $URLs = $URLs.Replace(" ","")
            $StrArray = $URLs.Split(",")
            $Objects += $StrArray
        }
        else {
            $Objects += $URLs
        }
    }

    if($CPCodes){
        # Validate data is only numberic plus comma
        if($CPCodes -notmatch "^[0-9,\s]+$"){
            throw "Format of CPCodes must be one or more numeric strings, separated by commas. '$CPCodes' is invalid"
        }

        if($CPCodes.Contains(",")) {
            $CPCodes = $CPCodes.Replace(" ","")
            $StrArray = $CPCodes.Split(",")
            # Convert strings to ints
            $IntArray = @()
            for($i = 0; $i -lt $StrArray.count; $i++){
                $IntArray += [int] $StrArray[$i]
            }
            $Objects += $IntArray
        }
        else{
            $Objects += [int] $CPCodes
        }
    }
    if($Tags){
        if($Tags.Contains(",")) {
            $Tags = $Tags.Replace(" ","")
            $StrArray = $Tags.Split(",")
            $Objects += $StrArray
        }
        else{
            $Objects += $Tags
        }
    }
    $PostBody = @{ 'objects' = $Objects }
    $PostJson = $PostBody | ConvertTo-Json -Depth 100

    $Path = "/ccu/v3/invalidate/$($PSCmdlet.ParameterSetName)/$($Network.ToLower())"

    try
    {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $PostJson
        return $Result
    }
    catch
    {
       throw $_.Exception 
    }
}

