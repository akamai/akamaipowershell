function Set-MasterZoneFile
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Zone,
        [Parameter(ParameterSetName='filename', Mandatory=$true)]  [string] $ZoneFilePath,
        [Parameter(ParameterSetName='contents', Mandatory=$true)]  [string] $ZoneFileContents,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($PSCmdlet.ParameterSetName -eq 'filename')
    {
        $Exists = Test-Path $ZoneFilePath
        if(!$Exists){
            throw "File '$ZoneFilePath' could not be found"
        }
        else{
            $ZoneFileContents = Get-Content -Raw $ZoneFilePath
        }
    }
    
    $Path = "/config-dns/v2/zones/$Zone/zone-file`?accountSwitchKey=$AccountSwitchKey"

    $AdditionalHeaders = @{
        'content-type' = 'text/dns'
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $ZoneFileContents -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}