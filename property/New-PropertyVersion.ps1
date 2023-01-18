function New-PropertyVersion
{
    Param(
        [Parameter(Mandatory=$false)] [string] $PropertyName,    
        [Parameter(Mandatory=$false)] [string] $PropertyID,
        [Parameter(ParameterSetName='attributes-version', Mandatory=$true)]  [string] $CreateFromVersion,
        [Parameter(ParameterSetName='attributes-etag', Mandatory=$true)]  [string] $CreateFromEtag,
        [Parameter(ParameterSetName='postbody', Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )
    
    if($PropertyName -eq '' -and $PropertyID -eq ''){
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
            throw $_
        }
    }

    if($PSCmdlet.ParameterSetName.StartsWith('attributes'))
    {
        if($CreateFromVersion){
            if($CreateFromVersion.ToLower() -eq "latest"){
                try{
                    if($PropertyName){
                        $CreateFromVersion = $Property.propertyVersion
                    }
                    else{
                        $Property = Get-Property -PropertyID $PropertyID -GroupID $GroupID -ContractId $ContractId -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
                        $CreateFromVersion = $Property.latestVersion
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
    
    $Path = "/papi/v1/properties/$PropertyID/versions?contractId=$ContractId&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}
