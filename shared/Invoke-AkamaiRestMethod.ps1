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
  Senior Technical Project Manager
  Akamai Technologies Inc.

  Adapted from Invoke-AkamaiOpen (https://github.com/akamai/AkamaiOPEN-edgegrid-powershell/blob/master/Invoke-AkamaiOPEN.ps1)

  Author: Josh Hicks
  Solutions Architect
  Akamai Technologies Inc.
  Copyright 2016
#>

<#
.SYNOPSIS
EdgeGrid Powershell
.DESCRIPTION
Authorization wrapper around Invoke-RestMethod for use with Akamai's OPEN API initiative.
.PARAMETER Method
Request method. Valid values are GET, POST, PUT, and DELETE
.PARAMETER Path
Request path without hostname or scheme, but including any request parameters
.PARAMETER EdgeRCFile
File-based Auth - Authorization file to read credentials from. Defaults to ~/.edgerc
.PARAMETER Section
File-based Auth - Section in EdgeRC file to read credentials from. Defaults to [default]
.PARAMETER Body
Should contain the POST/PUT Body. The body should be structured like a JSON object. Example: $Body = '{ "name": "botlist2", "type": "IP", "list": ["201.22.44.12", "8.7.6.0/24"] }'
.PARAMETER AdditionalHeaders
Hashtable of additional request headers to add
.PARAMETER Staging
Image Manager requests only. Changes IM host from production to staging. For non-IM requests does nothing.
.EXAMPLE
Invoke-AkamaiRestMethod -Method GET -Path '/path/to/api?withParams=true' -EdgeRCFile ~/my.edgerc -Section 'papi'
.LINK
developer.akamai.com
#>
function Invoke-AkamaiRestMethod
{
    param(
        [Parameter(Mandatory=$false)] [ValidateSet("GET", "PUT", "POST", "DELETE")] [string] $Method = "GET",
        [Parameter(Mandatory=$true)]  [string] $Path,
        [Parameter(Mandatory=$false)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [hashtable] $AdditionalHeaders,
        [Parameter(Mandatory=$false)] [boolean] $Staging,
        [Parameter(Mandatory=$false)] [string] $MaxBody = 131072
        )

    # Get credentials from EdgeRC
    if(!(Test-Path $EdgeRCFile)){
        throw "Error: EdgeRCFile $EdgeRCFile not found"
    }

    $Config = Get-Content $EdgeRCFile
    if("[$Section]" -notin $Config){
        throw "Error: Config section [$Section] not found in $EdgeRCFile"
    }

    $ConfigIndex = [array]::indexof($Config,"[$Section]")
    $SectionArray = $Config[$ConfigIndex..($ConfigIndex + 4)]
    $SectionArray | ForEach-Object {
        if($_.ToLower().StartsWith("client_token")) { $ClientToken = $_.Replace(" ","").SubString($_.IndexOf("=")) }
        if($_.ToLower().StartsWith("access_token")) { $ClientAccessToken = $_.Replace(" ","").SubString($_.IndexOf("=")) }
        if($_.ToLower().StartsWith("host"))         { $OpenHost = $_.Replace(" ","").SubString($_.IndexOf("=")) }
        if($_.ToLower().StartsWith("client_secret")){ $ClientSecret = $_.Replace(" ","").SubString($_.IndexOf("=")) }
    }

    if(!$ClientToken -or !$ClientAccessToken -or !$OpenHost -or !$ClientSecret){
        throw "Error: Some necessary auth elements missing. Please check your EdgeRC file"
    }

    # Set IM staging host if switch present
    if($OpenHost.Contains('.imaging.') -and $Staging) {
        $OpenHost = $OpenHost.Replace(".imaging.",".imaging-staging.")
    }

    # Set ReqURL from host and provided path
    $ReqURL = "https://" + $OpenHost + $Path

    #ReqURL Verification
    If ($null -eq ($ReqURL -as [System.URI]).AbsoluteURI -or $ReqURL -notmatch "akamaiapis.net")
    {
        throw "Error: Ivalid Request URI"
    }

    #Sanitize ReqURL (Certain {OPEN} APIs don't handle empty query parameters well)
    $ReqURL = Remove-NullQueryParameters -ReqURL $ReqURL

    #Sanitize Method param
    $Method = $Method.ToUpper()

    #Split $ReqURL for inclusion in SignatureData
    $ReqArray = $ReqURL -split "(.*\/{2})(.*?)(\/)(.*)"

    #Timestamp for request signing
    $TimeStamp = [DateTime]::UtcNow.ToString("yyyyMMddTHH:mm:sszz00")

    #GUID for request signing
    $Nonce = [GUID]::NewGuid()

    #Build data string for signature generation
    $SignatureData = $Method + "`thttps`t"
    $SignatureData += $ReqArray[2] + "`t" + $ReqArray[3] + $ReqArray[4]

    #Add body to signature. Truncate if body is greater than max-body (Akamai default is 131072). PUT Medthod does not require adding to signature.

    if ($Body -and $Method -eq "POST")
    {
        $Body_SHA256 = [System.Security.Cryptography.SHA256]::Create()
        if($Body.Length -gt $MaxBody){
            $Post_Hash = [System.Convert]::ToBase64String($Body_SHA256.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($Body.Substring(0,$MaxBody))))
        }
        else{
            $Post_Hash = [System.Convert]::ToBase64String($Body_SHA256.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($Body)))
        }

        $SignatureData += "`t`t" + $Post_Hash + "`t"
    }
    else
    {
        $SignatureData += "`t`t`t"
    }

    $SignatureData += "EG1-HMAC-SHA256 "
    $SignatureData += "client_token=" + $ClientToken + ";"
    $SignatureData += "access_token=" + $ClientAccessToken + ";"
    $SignatureData += "timestamp=" + $TimeStamp  + ";"
    $SignatureData += "nonce=" + $Nonce + ";"

    #Generate SigningKey
    $SigningKey = Crypto -secret $ClientSecret -message $TimeStamp

    #Generate Auth Signature
    $Signature = Crypto -secret $SigningKey -message $SignatureData

    #Create AuthHeader
    $AuthorizationHeader = "EG1-HMAC-SHA256 "
    $AuthorizationHeader += "client_token=" + $ClientToken + ";"
    $AuthorizationHeader += "access_token=" + $ClientAccessToken + ";"
    $AuthorizationHeader += "timestamp=" + $TimeStamp + ";"
    $AuthorizationHeader += "nonce=" + $Nonce + ";"
    $AuthorizationHeader += "signature=" + $Signature

    #Create IDictionary to hold request headers
    $Headers = @{}

    #Add Auth & Accept headers
    $Headers.Add('Authorization',$AuthorizationHeader)
    $Headers.Add('Accept','application/json')
    $Headers.Add('Content-Type', 'application/json')

    #Add additional headers
    if($AdditionalHeaders)
    {
        $AdditionalHeaders.Keys | foreach {
            $Headers[$_] = $AdditionalHeaders[$_]
        }
    }

    #Add additional headers if POSTing or PUTing
    If ($Body)
    {
      # turn off the "Expect: 100 Continue" header
      # as it's not supported on the Akamai side.
      [System.Net.ServicePointManager]::Expect100Continue = $false
    }

    #Check for valid Methods and required switches
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12


    # Check for Proxy Env variable and use if present
    if($null -ne $ENV:https_proxy)
    {
        $UseProxy = $true
    }

    if ($Method -eq "PUT" -or $Method -eq "POST") {
        try {
            if ($Body) {
                if($UseProxy){
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -Body $Body -Proxy $ENV:https_proxy
                }
                else {
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -Body $Body
                }

            }
            else {
                if($UseProxy) {
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -Proxy $ENV:https_proxy
                }
                else {
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers
                }
            }
        }
        catch {
            throw $_.ErrorDetails
        }
    }
    else {
        # Differentiate on PS 5 and later as PS 5's Invoke-RestMethod doesn't behave the same as the later versions
        if($PSVersionTable.PSVersion.Major -le 5){
            try{
                if($UseProxy) {
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -MaximumRedirection 0 -ErrorAction SilentlyContinue -Proxy $ENV:https_proxy
                }
                else {
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -MaximumRedirection 0 -ErrorAction SilentlyContinue
                }

                #Redirects aren't well handled due to signatures needing regenerated
                if($Response.redirectLink){
                    $Response = Invoke-AkamaiRestMethod -Method $Method -Path $Response.redirectLink  -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
                }
            }
            catch{
                throw $_.ErrorDetails
            }
        }
        else{
            try {
                if($UseProxy) {
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -MaximumRedirection 0 -ErrorAction Stop -Proxy $ENV:https_proxy
                }
                else {
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -MaximumRedirection 0 -ErrorAction Stop
                }
            }
            catch {
                #Redirects aren't well handled due to signatures needing regenerated
                if($_.Exception.Response.StatusCode.value__ -eq 301 -or $_.Exception.Response.StatusCode.value__ -eq 302)
                {
                    try {
                        $NewPath = $_.Exception.Response.Headers.Location.PathAndQuery
                        $Response = Invoke-AkamaiRestMethod -Method $Method -Path $NewPath -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
                    }
                    catch {
                        throw $_
                    }
                }
                else {
                    throw $_.ErrorDetails
                }
            }
        }
    }

    Return $Response
}
