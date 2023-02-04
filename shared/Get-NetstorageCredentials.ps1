<#
.SYNOPSIS
EdgeGrid Powershell - Core functions
.DESCRIPTION
Collect Netstorage auth credentials from environment variables or auth file
.PARAMETER AuthFile
Path to auth file
.PARAMETER Section
Auth file/env variable section
.EXAMPLE
Get-NetstorageCredentials
Get-NetstorageCredentials -AuthFile /path/to/auth -Section MySection
.LINK
techdocs.akamai.com
#>

function Get-NetstorageCredentials{
    param(
        [Parameter(Mandatory = $false)] [string] $AuthFile,
        [Parameter(Mandatory = $false)] [string] $Section
    )

    ## Assign defaults if values not provided
    if($AuthFile -eq ''){
        $AuthFile = '~/.akamai-cli/.netstorage/auth'
    }
    if($Section -eq ''){
        $Section = 'default'
    }


    #----------------------------------------------------------------------------------------------
    #                             1. Set up auth object
    #----------------------------------------------------------------------------------------------

    ## Instantiate auth object
    $AuthElements = @(
        'key',
        'id',
        'group',
        'host',
        'cpcode'
    )

    $Auth = New-Object -TypeName PSCustomObject
    $AuthElements | foreach{
        $Auth | Add-Member -MemberType NoteProperty -Name $_ -Value $null
    }

    #----------------------------------------------------------------------------------------------
    #                              2. Check for environment variables
    #----------------------------------------------------------------------------------------------
    
    ## 'default' section is implicit. Otherwise env variable starts with section prefix
    if($Section -eq 'default'){
        $EnvPrefix = 'NETSTORAGE_'
    }
    else{
        $EnvPrefix = "NETSTORAGE_$Section`_"
    }

    $AuthElements | foreach {
        $UpperEnv = "$EnvPrefix$_".ToUpper()
        if(Test-Path Env:\$UpperEnv){
            $Auth.$_ = (Get-Item -Path Env:\$UpperEnv).Value
        }
    }

    ## Check essential elements and return
    if($null -ne $Auth.key -and $null -ne $Auth.id -and $null -ne $Auth.group -and $null -ne $Auth.host -and $null -ne $Auth.cpcode){
        ## Env creds valid
        Write-Debug "Obtained credentials from environment variables in section '$Section'"
        return $Auth
    }

    #----------------------------------------------------------------------------------------------
    #                              3. Read from .edgerc file
    #----------------------------------------------------------------------------------------------

    # Get credentials from Auth file
    if(Test-Path $AuthFile){
        $AuthFileContent = Get-Content $AuthFile
        for($i = 0; $i -lt $AuthFileContent.length; $i++){
            $line = $AuthFileContent[$i]
            $SanitisedLine = $line.Replace(" ","")

            if($line.contains("[") -and $line.contains("]")){
                $SectionHeader = $SanitisedLine.Substring($Line.indexOf('[')+1)
                $SectionHeader = $SectionHeader.SubString(0,$SectionHeader.IndexOf(']'))
            }

            if($SanitisedLine.ToLower().StartsWith('key'))      { $Auth.key = $SanitisedLine.SubString($SanitisedLine.IndexOf("=") + 1) }
            if($SanitisedLine.ToLower().StartsWith('id'))       { $Auth.id = $SanitisedLine.SubString($SanitisedLine.IndexOf("=") + 1) }
            if($SanitisedLine.ToLower().StartsWith('group'))    { $Auth.group = $SanitisedLine.SubString($SanitisedLine.IndexOf("=") + 1) }
            if($SanitisedLine.ToLower().StartsWith('host'))     { $Auth.host = $SanitisedLine.SubString($SanitisedLine.IndexOf("=") + 1) }
            if($SanitisedLine.ToLower().StartsWith('cpcode'))   { $Auth.cpcode = $SanitisedLine.SubString($SanitisedLine.IndexOf("=") + 1) }
        }

        ## Check essential elements and return
        if($null -ne $Auth.key -and $null -ne $Auth.id -and $null -ne $Auth.group -and $null -ne $Auth.host -and $null -ne $Auth.cpcode){
            Write-Debug "Obtained credentials from auth file '$AuthFile' in section '$Section'"
            return $Auth
        }
    }
    
    #----------------------------------------------------------------------------------------------
    #                                     4. Panic!
    #----------------------------------------------------------------------------------------------

    ## Under normal circumstances you should not get this far...    
    throw "Error: Credentials could not be loaded from either; session, environment variables or edgerc file '$EdgeRCFile'"

}

