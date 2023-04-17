function New-MSLOrigin {
    Param(
        [Parameter(Mandatory = $true, ParameterSetName = 'pipeline', ValueFromPipeline = $true)]  [object] $Origin,
        [Parameter(Mandatory = $true, ParameterSetName = 'body')]  [string] $Body,
        [Parameter(Mandatory = $false)] [string] $EdgeRCFile,
        [Parameter(Mandatory = $false)] [string] $Section,
        [Parameter(Mandatory = $false)] [string] $AccountSwitchKey
    )

    begin {}

    process {
        $Path = "/config-media-live/v2/msl-origin/origins"

        if ($Origin) {
            $Body = $Origin | ConvertTo-Json -Depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            return $Result
        }
        catch {
            throw $_
        }
    }

    end {}    
}
