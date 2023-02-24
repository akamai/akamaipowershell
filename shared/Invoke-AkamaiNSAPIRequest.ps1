
#Requires -Version 3.0
<#
  Copyright 2019 Akamai Technologies, Inc. All Rights Reserved.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

  Author: Stuart Macleod
  Enterprise Architect
  Akamai Technologies Inc.
#>

<#
.SYNOPSIS
EdgeGrid Powershell
.DESCRIPTION
Authorization wrapper around Invoke-RestMethod for use with Akamai's Netstorage API
.PARAMETER Path
Request path, generally a file path beginning from the root of the file tree
.PARAMETER Action
API action, from predefined list
.PARAMETER AdditionalOptions
Hashtable of additional options to include in the request
.PARAMETER Body
Request body
.PARAMETER InputFile
Input file, typically for upload operations
.PARAMETER OutputFile
Output file, typically for download operations
.PARAMETER AuthFile
Fil-based Auth - text file holding credentials
.PARAMETER Section
File-based Auth - Section in auth file to read credentials from
.EXAMPLE
Invoke-AkamaiNSAPIRequest -Path $Path -Action 'download' -OutputFile ./localfile.txt
.LINK
developer.akamai.com
#>
function Invoke-AkamaiNSAPIRequest {
    Param(
        [Parameter(Mandatory=$true)] [string] $Path,
        [Parameter(Mandatory=$true)] [string] [ValidateSet('delete', 'dir', 'download', 'du', 'list', 'mkdir', 'mtime', 'quick-delete', 'rename', 'rmdir', 'stat', 'symlink', 'upload')] $Action,
        [Parameter(Mandatory=$false)] [Hashtable] $AdditionalOptions,
        [Parameter(Mandatory=$false)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $InputFile,
        [Parameter(Mandatory=$false)] [string] $OutputFile,
        [Parameter(Mandatory=$false)] [string] $AuthFile,
        [Parameter(Mandatory=$false)] [string] $Section
    )

    $Auth = Get-NetstorageCredentials -AuthFile $AuthFile -Section $Section

    # Check for Proxy Env variable and use if present
    if($null -ne $ENV:https_proxy)
    {
        $UseProxy = $true
    }

    #Prepend path with / and add CP Code
    $CPCode = $Auth.cpcode
    if(!($Path.StartsWith("/"))) {
        $Path = "/$Path"
    }
    if(!($Path.StartsWith("/$CPCode/"))) {
        $Path = "/$CPCode$Path"
    }
    # Do the same for any additional options that might be missing the CP Code prefix
    $PathFixAttributes = @( 
        'destination'
        'target'
    )
    $PathFixAttributes | foreach {
        if($AdditionalOptions -and $AdditionalOptions[$_] -and !($AdditionalOptions[$_].StartsWith("%2F$CPCode"))){
            $AdditionalOptions[$_] = "%2F$CPCode$($AdditionalOptions[$_])"
        }
    }

    $Headers = @{}
    
    # Action Header
    $Options = @{
        'version' = '1'
        'action' = $Action
    }
    if($AdditionalOptions){
        $Options += $AdditionalOptions
    }

    $Options.Keys | foreach {
        $ActionHeader += "$_=$($Options[$_])&"
    }

    if($ActionHeader.EndsWith("&")){
        $ActionHeader = $ActionHeader.Substring(0,$ActionHeader.LastIndexOf("&"))
    }
    # Remove null options
    $ActionHeader = Remove-NullQueryParameters -ReqURL $ActionHeader
    $Headers['X-Akamai-ACS-Action'] = $ActionHeader

    #GUID for request signing
    $Nonce = Get-RandomString -Length 20 -Hex

    # Generate X-Akamai-ACS-Auth-Data variable
    $Version = 5
    $EpochTime = [Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
    $AuthDataHeader = "$Version, 0.0.0.0, 0.0.0.0, $EpochTime, $Nonce, $($Auth.id)"
    $Headers['X-Akamai-ACS-Auth-Data'] = $AuthDataHeader

    # Create sign-string for encrypting, reuse shared Crypto
    $SignString = "$Path`nx-akamai-acs-action:$ActionHeader`n"
    $EncryptMessage = $AuthDataHeader + $SignString
    $Signature = Crypto -secret $Auth.key -message $EncryptMessage
    $Headers['X-Akamai-ACS-Auth-Sign'] = $Signature

    # Determine HTTP Method from Action
    Switch($Action) {
        'delete'       { $Method = "PUT"}
        'dir'          { $Method = "GET"}
        'download'     { $Method = "GET"}
        'du'           { $Method = "GET"}
        'list'         { $Method = "GET"}
        'mkdir'        { $Method = "PUT"}
        'mtime'        { $Method = "POST"}
        'quick-delete' { $Method = "POST"}
        'rename'       { $Method = "POST"}
        'rmdir'        { $Method = "POST"}
        'stat'         { $Method = "GET"}
        'symlink'      { $Method = "POST"}
        'upload'       { $Method = "PUT"}
    }

    # Set ReqURL from NSAPI hostname and supplied path
    $ReqURL = "https://$($Auth.host)" + $Path

    # Do it.
    if ($Method -eq "PUT" -or $Method -eq "POST") {
        try {
            if ($Body) {
                if($InputFile){
                    if($UseProxy){
                        $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -Body $Body -InFile $InputFile -Proxy $ENV:https_proxy
                    }
                    else {
                        $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -Body $Body -InFile $InputFile
                    }
                }
                else{
                    if($UseProxy){
                        $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -Body $Body -Proxy $ENV:https_proxy
                    }
                    else {
                        $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -Body $Body
                    }
                }
            }
            else {
                if($InputFile){
                    if($UseProxy) {
                        $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -InFile $InputFile -Proxy $ENV:https_proxy
                    }
                    else {
                        $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -InFile $InputFile
                    }
                }
                else {
                    if($UseProxy) {
                        $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -Proxy $ENV:https_proxy
                    }
                    else {
                        $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json'
                    }
                }
            }
        }
        catch {
            throw $_
        }
    }
    else {
        try {
            if($OutputFile){
                if($UseProxy) {
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -OutFile $OutputFile -MaximumRedirection 0 -ErrorAction Stop -Proxy $ENV:https_proxy
                }
                else {
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -OutFile $OutputFile -MaximumRedirection 0 -ErrorAction Stop
                }
            }
            else{
                if($UseProxy) {
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -MaximumRedirection 0 -ErrorAction Stop -Proxy $ENV:https_proxy
                }
                else {
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -MaximumRedirection 0 -ErrorAction Stop
                }
            }
        }
        catch {
            throw $_
        }
    }
    
    return $Response
}
