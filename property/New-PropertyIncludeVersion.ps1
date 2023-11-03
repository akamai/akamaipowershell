function New-PropertyIncludeVersion
{
    Param(
        [Parameter(Mandatory=$false)] [string] $IncludeName,
        [Parameter(Mandatory=$false)] [string] $IncludeID,
        [Parameter(ParameterSetName='attributes-version', Mandatory=$true)]  [string] $CreateFromVersion,
        [Parameter(ParameterSetName='attributes-etag', Mandatory=$true)]  [string] $CreateFromEtag,
        [Parameter(ParameterSetName='postbody', Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )
    
    if($IncludeName -eq '' -and $IncludeID -eq ''){
        throw "You must specify either an IncludeName or an IncludeID"
    }

    if($IncludeName){
        $Include = Find-Property -IncludeName $IncludeName -latest -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        if($null -eq $Include){
            throw "Include '$IncludeName' not found"
        }
        $IncludeID = $Include.includeId
    }

    if($PSCmdlet.ParameterSetName.StartsWith('attributes'))
    {
        if($CreateFromVersion){
            if($CreateFromVersion.ToLower() -eq "latest"){
                try{
                    if($IncludeName){
                        $CreateFromVersion = $Include.includeVersion
                    }
                    else{
                        $Include = Find-Property -IncludeName $IncludeName -latest -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
                        $CreateFromVersion = $Include.includeVersion
                    }
                }
                catch{
                    throw $_
                }
            }
    
            $PostObject = @{"createFromVersion"=$CreateFromVersion}
        }
        
        elseif($CreateFromEtag){
            $PostObject = @{"createFromEtag"=$CreateFromEtag}
        }

        $Body = $PostObject | ConvertTo-json
    }
    
    $Path = "/papi/v1/includes/$IncludeID/versions?contractId=$ContractId&groupId=$GroupID"
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
