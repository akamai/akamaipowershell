function New-Zone
{
    Param(
        [Parameter(ParameterSetName='attributes', Mandatory=$true)] [string] $Zone,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]  [string] [ValidateSet('PRIMARY','SECONDARY','ALIAS')] $Type,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] $Comment,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] $Masters,
        [Parameter(ParameterSetName='postbody', Mandatory=$true)] [string] $Body,
        [Parameter(Mandatory=$true)]  [string] $ContractID,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/config-dns/v2/zones?contractId=$ContractID&gid=$GroupID"

    if($PSCmdlet.ParameterSetName -eq 'attributes')
    {
        $BodyObj = @{
            zone = $Zone
            type = $Type
        }

        if($Comment){ $BodyObj['comment'] = $Comment }
        if($Masters){ $BodyObj['masters'] = ($Masters -split ",") }

        $Body = $BodyObj | ConvertTo-Json -Depth 100
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
