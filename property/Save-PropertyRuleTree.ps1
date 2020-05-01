function Get-RuleTree {
    Param(
        [Parameter(Mandatory=$true)]  [string] $Path,
        [Parameter(Mandatory=$false)] [switch] $IsDefault
    )

    $Rules = New-Object -TypeName PSCustomObject
    $Files = Get-ChildItem $Path

    # Differ on Windows or Unix paths
    if($Path.contains("\")){
        $FolderDelimiter = "\"
    }
    else{
        $FolderDelimiter = "/"
    }

    # Get Index content specifically
    $Index = ConvertFrom-Json -Depth 100 (Get-Content "$Path$FolderDelimiter`index.json" -Raw)

    if($IsDefault){
        $Rules | Add-Member -MemberType NoteProperty -Name 'name' -Value 'default'
        $Rules | Add-Member -MemberType NoteProperty -Name 'variables' -Value @()
        $Rules | Add-Member -MemberType NoteProperty -Name 'options' -Value $(New-Object -TypeName PSCustomObject)
    }
    else {
        $RuleName = $Path.Substring($Path.LastIndexOf($FolderDelimiter)+1)
        $Rules | Add-Member -MemberType NoteProperty -Name 'name' -Value $RuleName
    }

    $Rules | Add-Member -MemberType NoteProperty -Name 'children' -Value @()
    $Rules | Add-Member -MemberType NoteProperty -Name 'behaviors' -Value @()
    $Rules | Add-Member -MemberType NoteProperty -Name 'criteria' -Value @()
    $Rules | Add-Member -MemberType NoteProperty -Name 'criteriaMustSatisfy' -Value 'all'
    $Rules | Add-Member -MemberType NoteProperty -Name 'comments' -Value ''

    # First do general options
    foreach($File in $Files){
        if($File.BaseName -eq "criteria"){
            $Criteria = ConvertFrom-Json (Get-Content $File.FullName -Raw)
            # Differ on whether criteria is already an array or just a single item
            if($Criteria.Count -gt 1){
                $Rules.criteria = $Criteria
            }
            else{
                $Rules.criteria += $Criteria
            }
        }
        elseif($File.BaseName -eq "criteriaMustSatisfy"){
            $Rules.criteriaMustSatisfy = ConvertFrom-Json (Get-Content $File.FullName -Raw)
        }
        elseif($File.BaseName -eq "options"){
            $Rules.options = ConvertFrom-Json (Get-Content $File.FullName -Raw)
        }
        elseif($File.BaseName -eq "variables"){
            $Rules.variables = ConvertFrom-Json (Get-Content $File.FullName -Raw)
        }
        elseif($File.BaseName -eq "comments"){
            $Rules.comments = ConvertFrom-Json (Get-Content $File.FullName -Raw)
        }
    }

    # Next iterate through index members for behaviors and children
    foreach($Behavior in $Index.behaviors){
        $BehaviorFile = $Files | where {$_.Name -eq "$Behavior.json"}
        $Rules.behaviors += ConvertFrom-Json (Get-Content $BehaviorFile.FullName -Raw)
    }
    foreach($Child in $Index.children){
        $Rules.children += Get-RuleTree -Path "$Path$FolderDelimiter$Child"
    }

    return $Rules
}

function Save-PropertyRuleTree
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $PropertyName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$false)] [string] $PropertyVersion,
        [Parameter(Mandatory=$true)]  [string] $SourceFolder,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey,
        [Parameter(Mandatory=$false)] [switch] $Clobber,
        [Parameter(Mandatory=$false)] [string] $loglevel = 'info'
    )

    # Check folder exists
    if(!(Test-Path $SourceFolder)){
        Throw "Can't find source folder $($SourceFolder)"
    }

    # Construct Rule Tree
    $SourceFolderPath = (Get-Item $SourceFolder).FullName
    if($loglevel -eq 'debug'){
        Write-Host "DEBUG: Constructing rule tree from folder $SourceFolderPath"
    }
    $RuleTree = New-Object -TypeName PSCustomObject
    $RuleTree | Add-Member -MemberType NoteProperty -Name "rules" -Value $(New-Object -TypeName PSCustomObject)
    $RuleTree.rules = Get-RuleTree -Path $SourceFolderPath -IsDefault
    $PostBody = $RuleTree | ConvertTo-Json -Depth 100

    # Get Property info from PAPI
    if($PropertyName){
        if($loglevel -eq 'debug'){
            Write-Host "DEBUG: Polling PAPI for property '$PropertyName'"
        }
        $Property = Get-Property -PropertyName $PropertyName -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
    }
    else{
        if($loglevel -eq 'debug'){
            Write-Host "DEBUG: Polling PAPI for property '$PropertyId'"
        }
        $Property = Get-Property -PropertyId $PropertyId -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
    }

    if($loglevel -eq 'debug'){
        Write-Host "DEBUG: Found Property"
        $Property
    }
    
    # Get Version status
    if($PropertyVersion -and $PropertyVersion.ToLower() -ne "latest"){
        if($loglevel -eq 'debug'){
            Write-Host "DEBUG: Getting status of version $PropertyVersion of property $($Property.propertyId)"
        }
        $PAPIVersion = Get-PropertyVersion -PropertyId $Property.propertyId -PropertyVersion $PropertyVersion -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
    }
    else{
        if($loglevel -eq 'debug'){
            Write-Host "DEBUG: Getting status of latest version of property $($Property.propertyId)"
        }
        $PAPIVersion = Get-PropertyVersion -PropertyId $Property.propertyId -PropertyVersion $Property.latestVersion -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        $PropertyVersion = $Property.latestVersion
    }

    if($loglevel -eq 'debug'){
        Write-Host "DEBUG: Found Property version"
        $PAPIVersion
    }

    # Check if saved ETAG matches PAPI one. Protects against PAPI changes you don't want to overwrite
    if(!$Clobber){
        if(Test-Path "$SourceFolderPath\etag.txt"){
            # Only try to compare if local etag exists. If not, don't worry about it
            $LocalEtag = Get-Content "$SourceFolderPath\etag.txt"
            if($loglevel -eq 'debug'){
                Write-Host "DEBUG: Local etag = $LocalEtag"
            }
            if($PAPIVersion.etag -ne $LocalEtag){
                throw "ERROR: Local etag does not match etag pulled from PAPI. If you wish to override this use '-Clobber'"
            }
        }
    }

    # Create new version if latest version is active in either network or has been deactivated
    if($PAPIVersion.productionStatus -ne "INACTIVE" -or $PAPIVersion.stagingStatus -ne "INACTIVE"){
        if($loglevel -eq 'debug'){
            Write-Host "DEBUG: Property is not in INACTIVE state on both networks so creating new version..."
        }
        $NewVersionResult = New-PropertyVersion -PropertyId $Property.propertyId -CreateFromVersion $PropertyVersion -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        # Extract new version number from PAPI response
        $PropertyVersion = $NewVersionResult.versionLink.Substring($NewVersionResult.versionLink.LastIndexOf("/")+1,1)
        Write-Host -ForegroundColor Yellow "Information: Created new version ($PropertyVersion) of $($property.PropertyName)"
    }

    try {
        if($loglevel -eq 'debug'){
            Write-Host "DEBUG: POSTing new rule tree to property"
        }  
        $Result = Set-PropertyRuleTree -PropertyId $Property.propertyId -PropertyVersion $PropertyVersion -Body $PostBody -GroupID $GroupID -ContractId $ContractId -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        Set-Content -Value $Result.etag -Path "$SourceFolderPath\etag.txt" -NoNewline
        return $Result
    }
    catch {
        throw $_.Exception
    }
}