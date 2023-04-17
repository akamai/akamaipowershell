<#
.SYNOPSIS
EdgeGrid Powershell - Core functions
.DESCRIPTION
Collect EdgeGrid credentials from session, environment variables, or auth file
.PARAMETER EdgeRCFile
Path to .edgerc file, defaults to ~/.edgerc. OPTIONAL
.PARAMETER ContractId
.edgerc Section name. Defaults to 'default'. OPTIONAL
.PARAMETER AccountSwitchKey
Account switch key if applying to an account external to yoru API user. Only usable by Akamai staff and partners. OPTIONAL
.EXAMPLE
Get-AkamaiCredentials
Get-AkamaiCredentials -Section 'notdefault' -AccountSwitchKey my-ask
.LINK
techdocs.akamai.com
#>

function Get-AkamaiCredentials{
    param(
        [Parameter(Mandatory = $false)] [string] $EdgeRCFile,
        [Parameter(Mandatory = $false)] [string] $Section,
        [Parameter(Mandatory = $false)] [string] $AccountSwitchKey
    )

    ## Assign defaults if values not provided
    if($EdgeRCFile -eq ''){
        $EdgeRCFile = '~/.edgerc'
    }
    else{
        ## If EdgeRCFile is provided we use that, regardless of other auth types being available
        $Mode = 'edgerc'
    }
    if($Section -eq ''){
        $Section = 'default'
    }

    #----------------------------------------------------------------------------------------------
    #                              1. Check for existing session
    #----------------------------------------------------------------------------------------------

    if($Mode -ne 'edgerc'){
        if ($null -ne $Script:AkamaiSession -and $null -ne $Script:AkamaiSession.Auth.$Section) {
            #Use the script session auth instead of a file
            $Auth = $Script:AkamaiSession.Auth.$Section
            Write-Debug "Obtained credentials from existing session in section '$Section'"
            return $Auth
        }
    }   
    

    #----------------------------------------------------------------------------------------------
    #                             2. Set up auth object
    #----------------------------------------------------------------------------------------------

    ## Instantiate auth object
    $AuthElements = @(
        'host',
        'client_token',
        'access_token',
        'client_secret',
        'account_key'
    )

    $Auth = New-Object -TypeName PSCustomObject
    $AuthElements | foreach{
        $Auth | Add-Member -MemberType NoteProperty -Name $_ -Value $null
    }

    #----------------------------------------------------------------------------------------------
    #                              3. Check for environment variables
    #----------------------------------------------------------------------------------------------
    
    ## 'default' section is implicit. Otherwise env variable starts with section prefix
    if($Mode -ne 'edgerc'){
        if($Section -eq 'default'){
            $EnvPrefix = 'AKAMAI_'
        }
        else{
            $EnvPrefix = "AKAMAI_$Section`_"
        }
    
        $AuthElements | foreach {
            $UpperEnv = "$EnvPrefix$_".ToUpper()
            if(Test-Path Env:\$UpperEnv){
                $Auth.$_ = (Get-Item -Path Env:\$UpperEnv).Value
            }
        }

        ## Explicit ASK wins over env variable
        if($AccountSwitchKey){
            $Auth.account_key = $AccountSwitchKey
        }

        ## Check essential elements and return
        if($null -ne $Auth.host -and $null -ne $Auth.client_token -and $null -ne $Auth.access_token -and $null -ne $Auth.client_secret){
            ## Env creds valid
            Write-Debug "Obtained credentials from environment variables in section '$Section'"
            return $Auth
        }
    }

    #----------------------------------------------------------------------------------------------
    #                              4. Read from .edgerc file
    #----------------------------------------------------------------------------------------------

    # Get credentials from EdgeRC
    if(Test-Path $EdgeRCFile){
        $EdgeRCContent = Get-Content $EdgeRCFile
        foreach($line in $EdgeRCContent){
            $SanitizedLine = $line.Replace(" ","")

            ## Set SectionHeader variable if line is a header.
            if($SanitizedLine.contains("[") -and $SanitizedLine.contains("]")){
                $SectionHeader = $SanitizedLine.Substring($SanitizedLine.indexOf('[')+1)
                $SectionHeader = $SectionHeader.SubString(0,$SectionHeader.IndexOf(']'))
            }

            ## Skip sections other than desired one
            if($SectionHeader -ne $Section){ continue }

            if($SanitizedLine.ToLower().StartsWith("client_token")) { $Auth.client_token = $SanitizedLine.SubString($SanitizedLine.IndexOf("=") + 1) }
            if($SanitizedLine.ToLower().StartsWith("access_token")) { $Auth.access_token = $SanitizedLine.SubString($SanitizedLine.IndexOf("=") + 1) }
            if($SanitizedLine.ToLower().StartsWith("host"))         { $Auth.host = $SanitizedLine.SubString($SanitizedLine.IndexOf("=") + 1) }
            if($SanitizedLine.ToLower().StartsWith("client_secret")){ $Auth.client_secret = $SanitizedLine.SubString($SanitizedLine.IndexOf("=") + 1) }
            if($SanitizedLine.ToLower().StartsWith("account_key")){ $Auth.account_key = $SanitizedLine.SubString($SanitizedLine.IndexOf("=") + 1) }
        }

        ## Explicit ASK wins over edgerc file entry
        if($AccountSwitchKey){
            $Auth.account_key = $AccountSwitchKey
        }

        ## Check essential elements and return
        if($null -ne $Auth.host -and $null -ne $Auth.client_token -and $null -ne $Auth.access_token -and $null -ne $Auth.client_secret){
            Write-Debug "Obtained credentials from edgerc file '$EdgeRCFile' in section '$Section'"
            return $Auth
        }
    }
    
    #----------------------------------------------------------------------------------------------
    #                                     5. Panic!
    #----------------------------------------------------------------------------------------------

    ## Under normal circumstances you should not get this far...    
    throw "Error: Credentials could not be loaded from either; session, environment variables or edgerc file '$EdgeRCFile'"

}

