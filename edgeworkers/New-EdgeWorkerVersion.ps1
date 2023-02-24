function New-EdgeWorkerVersion
{
    [CmdletBinding(DefaultParameterSetName = 'name')]
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $Name,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $EdgeWorkerID,
        [Parameter(Mandatory=$false)] [string] $CodeDirectory,
        [Parameter(Mandatory=$false)] [string] $CodeBundle,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($CodeDirectory -ne '' -and $CodeBundle -ne ''){
        throw "Specify only one of -CodeDirectory or -CodeBundle"
    }

    if($Name -or $CodeDirectory){
        try{
            $EdgeWorker = (List-EdgeWorkers -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey) | Where {$_.name -eq $Name}
            if($EdgeWorker.count -gt 1){
                throw "Found multiple EdgeWorkers with name $Name. Use -EdgeWorkerID to be more specific"
            }
            $EdgeWorkerID = $EdgeWorker.edgeWorkerId
            $EdgeWorkerName = $EdgeWorker.name
            if(!$EdgeWorkerID){
                throw "EdgeWorker $Name not found"
            }
        }
        catch{
            throw $_
        }
    }

    if($CodeDirectory){
        if( Get-Command tar -ErrorAction SilentlyContinue){
            $Directory = Get-Item $CodeDirectory
            $Slash = Get-OSSlashCharacter
            $Bundle = ConvertFrom-Json (Get-Content "$($Directory.FullName)$($Slash)bundle.json" -Raw) 
            $Version = $Bundle.'edgeworker-version'
            $CodeBundleFileName = "$EdgeWorkerName-$Version.tgz"
            
            $CodeBundle = "$($Directory.FullName)$Slash$CodeBundleFileName"

            # Create bundle
            Write-Debug "Creating tarball $CodeBundle from directory $($Directory.fullName)"
            $CurrentDir = Get-Location
            Set-Location $Directory.FullName
            tar -czf $CodeBundle --exclude=*.tgz * | Out-Null
            Set-Location $CurrentDir
        }
        else{
            throw "tar command not found. Please create .tgz file manually and use -CodeBundle parameter"
        }
    }

    if(!(Test-Path $CodeBundle)){
        throw "Code Bundle $CodeBundle could not be found"
    }

    $Path = "/edgeworkers/v1/ids/$EdgeWorkerID/versions"
    $AdditionalHeaders = @{
        'Content-Type' = 'application/gzip'
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -InputFile $CodeBundle -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
