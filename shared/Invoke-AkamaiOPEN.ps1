#Requires -Version 3.0
<#
  Copyright 2013 Akamai Technologies, Inc. All Rights Reserved.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

  Author: Josh Hicks
  Solutions Architect
  Akamai Technologies Inc.
#>

<#
.SYNOPSIS
EdgeGrid Powershell
.DESCRIPTION
Authorization wrapper around Invoke-RestMethod for use with Akamai's OPEN API initiative.
.PARAMETER Method
Request method. Valid values are GET, POST, PUT, and DELETE
.PARAMETER ClientToken
Authentication token used in client auth. Available in Luna Portal.
.PARAMETER ClientAccessToken
Authentication token used in client auth. Available in Luna Portal.
.PARAMETER ClientSecret
Authentication password used in client auth. Available in Luna Portal.
.PARAMETER ReqURL
Full request URL complete with API location and parameters. Must be URL encoded.
.PARAMETER Body
Should contain the POST/PUT Body. The body should be structured like a JSON object. Example: $Body = '{ "name": "botlist2", "type": "IP", "list": ["201.22.44.12", "8.7.6.0/24"] }'
.EXAMPLE
Invoke-AkamaiOPEN -Method GET -ClientToken "foo" -ClientAccessToken "foo" -ClientSecret "foo" -ReqURL "https://foo.luna.akamaiapis.net/diagnostic-tools/v1/locations"
.LINK
developer.akamai.com
#>
function Invoke-AkamaiOPEN
{
    param(
        [Parameter(Mandatory=$true)] [ValidateSet("GET", "PUT", "POST", "DELETE")] [string]$Method,
        [Parameter(Mandatory=$true)] [string]$ClientToken,
        [Parameter(Mandatory=$true)] [string]$ClientAccessToken,
        [Parameter(Mandatory=$true)] [string]$ClientSecret,
        [Parameter(Mandatory=$true)] [string]$ReqURL,
        [Parameter(Mandatory=$false)][string]$Body,
        [Parameter(Mandatory=$false)][string]$MaxBody = 131072
        )

    #Function to generate HMAC SHA256 Base64
    Function Crypto ($secret, $message)
    {
        [byte[]] $keyByte = [System.Text.Encoding]::ASCII.GetBytes($secret)
        [byte[]] $messageBytes = [System.Text.Encoding]::ASCII.GetBytes($message)
        $hmac = new-object System.Security.Cryptography.HMACSHA256((,$keyByte))
        [byte[]] $hashmessage = $hmac.ComputeHash($messageBytes)
        $Crypt = [System.Convert]::ToBase64String($hashmessage)

        return $Crypt
    }

    #ReqURL Verification
    If (($ReqURL -as [System.URI]).AbsoluteURI -eq $null -or $ReqURL -notmatch "akamaiapis.net")
    {
        throw "Error: Ivalid Request URI"
    }

    #Sanitize ReqURL (Certain {OOPEN} APIs don't handle empty query parameters well)
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

    #Add Auth header
    $Headers.Add('Authorization',$AuthorizationHeader)

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
    if($ENV:https_proxy -ne $null)
    {
        $UseProxy = $true
    }

    if ($Method -eq "PUT" -or $Method -eq "POST") {
        try {
            if ($Body) {
                if($UseProxy){
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -Body $Body -ContentType 'application/json' -Proxy $ENV:https_proxy
                }
                else {
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -Body $Body -ContentType 'application/json'
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
        catch {
            throw $_.ErrorDetails
        }
    }
    else {
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
                    $NewReqURL = "https://" + $_.Exception.Response.Headers.Location.Host + $_.Exception.Response.Headers.Location.PathAndQuery
                    if($UseProxy) {
                        Invoke-AkamaiOPEN -Method $Method -ClientToken $ClientToken -ClientAccessToken $ClientAccessToken -ClientSecret $ClientSecret -ReqURL $NewReqURL -Proxy $ENV:https_proxy
                    }
                    else {
                        Invoke-AkamaiOPEN -Method $Method -ClientToken $ClientToken -ClientAccessToken $ClientAccessToken -ClientSecret $ClientSecret -ReqURL $NewReqURL
                    }
                }
                catch {
                    throw $_.ErrorDetails
                }
            }
            else {
                throw $_.ErrorDetails
            }
        }
    }

    Return $Response
}
