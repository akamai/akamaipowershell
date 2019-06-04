function New-PropertyVersion
{
    Param(
        [Parameter(Mandatory=$true)] [string] $PropertyId,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)]  [int] $CreateFromVersion,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)]  [string] $CreateFromEtag,
        [Parameter(ParameterSetName='postbody', Mandatory=$false)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/properties/$PropertyId/versions/?contractId=$ContractId&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"
    
    if($PSCmdlet.ParameterSetName -eq 'attributes')
    {
        if($CreateFromVersion -eq '' -and $CreateFromEtag -eq '')
        {
            return "If specifying attributes you must provide at least one of: CreateFromVersion, CreateFromEtag"
        }
        $PostObject = @{"createFromVersion"=$CreateFromVersion}
        $Body = $PostObject | Convertto-json
    }
    
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $Body
        write-host "New Version Created"
        return $Result
    }
    catch {
        throw $_.Exception
    }
}

