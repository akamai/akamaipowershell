function New-EdgeWorkerVersion
{
    [CmdletBinding(DefaultParameterSetName = 'name')]
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $Name,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $EdgeWorkerID,
        [Parameter(Mandatory=$false)] [string] $CodeDirectory,
        [Parameter(Mandatory=$false)] [string] $CodeBundle,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($CodeDirectory -ne '' -and $CodeBundle -ne ''){
        throw "Specify only one of -CodeDirectory or -CodeBundle"
    }

    if($Name){
        try{
            $EdgeWorker = (List-EdgeWorkers -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey) | Where {$_.name -eq $Name}
            if($EdgeWorker.count -gt 1){
                throw "Found multiple EdgeWorkers with name $Name. Use -EdgeWorkerID to be more specific"
            }
            $EdgeWorkerID = $EdgeWorker.edgeWorkerId
            if(!$EdgeWorkerID){
                throw "EdgeWorker $Name not found"
            }
        }
        catch{
            throw $_.Exception
        }
    }

    if($CodeDirectory){
        if( Get-Command tar -ErrorAction SilentlyContinue){
            $Directory = Get-Item $CodeDirectory
            $Bundle = Get-Content "$($Directory.FullName)\bundle.json" | ConvertFrom-Json
            $Version = $Bundle.'edgeworker-version'
            $CodeBundleFileName = "$($Directory.Name)-$Version.tgz"
            $CodeBundle = "$($Directory.FullName)\$CodeBundleFileName"

            # Create bundle
            Write-Debug "Creating tarball $CodeBundle from directory $($Directory.fullName)"
            tar -czf $CodeBundle -C $Directory.FullName --exclude=*.tgz * | Out-Null
        }
        else{
            throw "tar command not found. Please create .tgz file manually and use -CodeBundle parameter"
        }
    }

    if(!(Test-Path $CodeBundle)){
        throw "Code Bundle $CodeBundle could not be found"
    }

    $Path = "/edgeworkers/v1/ids/$EdgeWorkerID/versions?accountSwitchKey=$AccountSwitchKey"
    $AdditionalHeaders = @{
        'Content-Type' = 'application/gzip'
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -InputFile $CodeBundle -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}