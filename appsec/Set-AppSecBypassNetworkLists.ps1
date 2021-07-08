function Set-AppSecBypasNetworkLists
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $ConfigName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]    [string] $ConfigID,
        [Parameter(Mandatory=$true)]  [string] $VersionNumber,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)] [object[]] $NetworkLists,
        [Parameter(Mandatory=$false)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{
        if($ConfigName){
            $Config = List-AppSecConfigurations -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey | where {$_.name -eq $ConfigName}
            if($Config){
                $ConfigID = $Config.id
            }
            else{
                throw("Security config '$ConfigName' not found")
            }
        }
    
        if($NetworkLists.count -gt 0){
            $VersionNumber = (List-AppSecConfigurationVersions -ConfigID $ConfigID -PageSize 1 -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey).version
        }

        if($PSCmdlet.ParameterSetName -eq 'pipeline'){
            $CombinedNLArray = New-Object -TypeName System.Collections.ArrayList
        }
    
        $Path = "/appsec/v1/configs/$ConfigID/versions/$VersionNumber/bypass-network-lists?accountSwitchKey=$AccountSwitchKey"    
    }

    process{
        if($NetworkLists.count -gt 0){
            foreach($NetworkList in $NetworkLists){
                $CombinedNLArray.Add($NetworkList) | Out-Null
            }
        }
    }

    end{
        if($NetworkLists.count -gt 0){
            $Body = $CombinedNLArray | ConvertTo-Json -Depth 100 -AsArray
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_.Exception 
        }
    }
}