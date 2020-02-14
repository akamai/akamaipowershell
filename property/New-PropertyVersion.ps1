function New-PropertyVersion
{
    Param(
        [Parameter(Mandatory=$false)] [string] $PropertyName,    
        [Parameter(Mandatory=$false)] [string] $PropertyId,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)]  [string] $CreateFromVersion,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)]  [string] $CreateFromEtag,
        [Parameter(ParameterSetName='postbody', Mandatory=$false)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )
    
    if($PropertyName -eq '' -and $PropertyId -eq ''){
        throw "You must specify either a PropertyName or a PropertyID"
    }

    if($PropertyName){
        try{
            $Property = Find-Property -PropertyName $PropertyName -latest -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            $PropertyID = $Property.propertyId
            if($PropertyID -eq ''){
                throw "Property '$PropertyName' not found"
            }
        }
        catch{
            throw $_.Exception
        }
    }

    if($PSCmdlet.ParameterSetName -eq 'attributes')
    {
        if($CreateFromVersion -eq '' -and $CreateFromEtag -eq '')
        {
            return "If specifying attributes you must provide at least one of: CreateFromVersion, CreateFromEtag"
        }

        if($CreateFromVersion){
            if($CreateFromVersion.ToLower() -eq "latest"){
                try{
                    if($PropertyName){
                        $CreateFromVersion = $Property.propertyVersion
                    }
                    else{
                        $Property = Get-Property -PropertyId $PropertyID -GroupID $GroupID -ContractId $ContractId -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
                        $CreateFromVersion = $Property.latestVersion
                    }
                }
                catch{
                    throw $_.Exception
                }
            }
    
            $PostObject = @{"createFromVersion"=$CreateFromVersion}
        }
        
        if($CreateFromEtag){
            $PostObject = @{"createFromEtag"=$CreateFromEtag}
        }

        $Body = $PostObject | Convertto-json
    }
    
    $Path = "/papi/v1/properties/$PropertyId/versions?contractId=$ContractId&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $Body
        return $Result
    }
    catch {
        throw $_.Exception
    }
}

