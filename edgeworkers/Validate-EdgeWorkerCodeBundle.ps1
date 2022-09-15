function Validate-EdgeWorkerCodeBundle
{
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='directory')]  [string] $CodeDirectory,
        [Parameter(Mandatory=$true,ParameterSetName='bundle')]     [string] $CodeBundle,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

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

    $Path = "/edgeworkers/v1/validations?accountSwitchKey=$AccountSwitchKey"
    $AdditionalHeaders = @{
        'Content-Type' = 'application/gzip'
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -InputFile $CodeBundle -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}
