function Set-RecordSet
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Zone,
        [Parameter(Mandatory=$true)]  [string] $Name,
        [Parameter(Mandatory=$true)]  [string] $Type,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]  [string] $TTL,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]  [string] $RData,
        [Parameter(ParameterSetName='postbody',   Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/config-dns/v2/zones/$Zone/names/$Name/types/$Type"

    if($PSCmdlet.ParameterSetName -eq 'attributes')
    {
        $RDataArray = $RData.split(",")
        $BodyObj = @{
            name = $Name
            type = $Type
            ttl = $TTL
            rdata = $RDataArray
        }
        $Body = $BodyObj | ConvertTo-Json -Depth 100
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
