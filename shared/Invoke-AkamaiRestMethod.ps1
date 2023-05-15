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
.PARAMETER AccountSwitchKey
Switch key to be used by Akamai Partners or internal users in order to apply a command to another account
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
function Invoke-AkamaiRestMethod {
    param(
        [Parameter(Mandatory = $false)] [ValidateSet("GET", "PUT", "POST", "DELETE", "PATCH")] [string] $Method = "GET",
        [Parameter(Mandatory = $true)]  [string] $Path,
        [Parameter(Mandatory = $false)] $Body,
        [Parameter(Mandatory = $false)] [string] $InputFile,
        [Parameter(Mandatory = $false)] [string] $OutputFile,
        [Parameter(Mandatory = $false)] [string] $EdgeRCFile,
        [Parameter(Mandatory = $false)] [string] $Section,
        [Parameter(Mandatory = $false)] [string] $AccountSwitchKey,
        [Parameter(Mandatory = $false)] [hashtable] $AdditionalHeaders,
        [Parameter(Mandatory = $false)] [string] $MaxBody = 131072,
        [Parameter(Mandatory = $false)] [string] $ResponseHeadersVariable
    )

    # Get auth creds from various potential sources
    $Auth = Get-AkamaiCredentials -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
    if($Debug){
        ## Check creds if in Debug mode
        Test-Auth -Auth $Auth
    }

    # Add account switch key from $Auth, if present
    if($Auth.account_key){
        if($Path.Contains('?')){ $Path += '&' }
        else{ $Path += '?' }
        $Path += "accountSwitchKey=$($Auth.account_key)"
    }

    # Sanitize query string
    if ($Path.Contains('?')) {
        $PathElements = $Path.Split('?')
        $PathOnly = $PathElements[0]
        $QueryString = $PathElements[1]
        $SanitizedQuery = Sanitize-QueryString -QueryString $QueryString
        Write-Debug "Original Query = $QueryString"
        Write-Debug "Sanitized Query = $SanitizedQuery"
        # Reconstruct Path
        if ($SanitizedQuery) {
            $Path = $PathOnly + '?' + $SanitizedQuery
        }
        else {
            $Path = $PathOnly
        }
    }

    # Set ReqURL from host and provided path
    $ReqURL = "https://" + $Auth.host + $Path

    # ReqURL Verification
    Write-Debug "Request URL = $ReqURL"
    If ($null -eq ($ReqURL -as [System.URI]).AbsoluteURI -or $ReqURL -notmatch "akamaiapis.net") {
        throw "Error: Invalid Request URI"
    }

    # Sanitize Method param
    $Method = $Method.ToUpper()

    # Timestamp for request signing
    $TimeStamp = [DateTime]::UtcNow.ToString("yyyyMMddTHH:mm:sszz00")

    # GUID for request signing
    $Nonce = [GUID]::NewGuid()

    # Build data string for signature generation
    $SignatureData = $Method + "`thttps`t"
    $SignatureData += $Auth.host + "`t" + $Path

    # Add body to signature. Truncate if body is greater than max-body (Akamai default is 131072). PUT Method does not require adding to signature.
    if ($Method -eq "POST") {
        if ($Body) {
            $Body_SHA256 = [System.Security.Cryptography.SHA256]::Create()
            if ($Body.Length -gt $MaxBody) {
                $Body_Hash = [System.Convert]::ToBase64String($Body_SHA256.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($Body.Substring(0, $MaxBody))))
            }
            else {
                $Body_Hash = [System.Convert]::ToBase64String($Body_SHA256.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($Body)))
            }

            $SignatureData += "`t`t" + $Body_Hash + "`t"
        }
        elseif ($InputFile) {
            $Body_SHA256 = [System.Security.Cryptography.SHA256]::Create()
            if($PSVersionTable.PSVersion.Major -le 5) {
                $Bytes = Get-Content $InputFile -Encoding Byte
            }
            else{
                $Bytes = Get-Content $InputFile -AsByteStream
            }

            if ($Bytes.Length -gt $MaxBody) {
                $Body_Hash = [System.Convert]::ToBase64String($Body_SHA256.ComputeHash($Bytes[0..($MaxBody - 1)]))
            }
            else {
                $Body_Hash = [System.Convert]::ToBase64String($Body_SHA256.ComputeHash($Bytes))
            }

            $SignatureData += "`t`t" + $Body_Hash + "`t"
            Write-Debug "Signature generated from input file $InputFile"
        }
        else {
            $SignatureData += "`t`t`t"
        }
    }
    else {
        $SignatureData += "`t`t`t"
    }

    $SignatureData += "EG1-HMAC-SHA256 "
    $SignatureData += "client_token=" + $Auth.client_token + ";"
    $SignatureData += "access_token=" + $Auth.access_token + ";"
    $SignatureData += "timestamp=" + $TimeStamp + ";"
    $SignatureData += "nonce=" + $Nonce + ";"

    Write-Debug "SignatureData = $SignatureData"

    # Generate SigningKey
    $SigningKey = Crypto -secret $Auth.client_secret -message $TimeStamp

    # Generate Auth Signature
    $Signature = Crypto -secret $SigningKey -message $SignatureData

    # Create AuthHeader
    $AuthorizationHeader = "EG1-HMAC-SHA256 "
    $AuthorizationHeader += "client_token=" + $Auth.client_token + ";"
    $AuthorizationHeader += "access_token=" + $Auth.access_token + ";"
    $AuthorizationHeader += "timestamp=" + $TimeStamp + ";"
    $AuthorizationHeader += "nonce=" + $Nonce + ";"
    $AuthorizationHeader += "signature=" + $Signature

    # Create IDictionary to hold request headers
    $Headers = @{}

    ## Calculate custom UA
    if($PSVersionTable.PSVersion.Major -ge 6){ #< 6 is missing the OS member of PSVersionTable, so we use env variables
        $UserAgent = "AkamaiPowershell/$($Env:AkamaiPowershellVersion) (Powershell $PSEdition $($PSVersionTable.PSVersion) $PSCulture, $($PSVersionTable.OS))"
    }
    else{
        $UserAgent = "AkamaiPowershell/$($Env:AkamaiPowershellVersion) (Powershell $PSEdition $($PSVersionTable.PSVersion) $PSCulture, $($Env:OS))"
    }
    
    # Add headers
    $Headers.Add('Authorization',$AuthorizationHeader)
    $Headers.Add('Accept','application/json')
    $Headers.Add('Content-Type', 'application/json; charset=utf-8')
    $Headers.Add('User-Agent', $UserAgent)

    # Add additional headers
    if ($AdditionalHeaders) {
        $AdditionalHeaders.Keys | ForEach-Object {
            $Headers[$_] = $AdditionalHeaders[$_]
        }
    }

    # Set ContentType param from Content-Type header. This is sent along with bodies to fix string encoding issues in IRM
    $ContentType = $Headers['Content-Type']

    # Add additional headers if POSTing or PUTing
    If ($Body) {
        # turn off the "Expect: 100 Continue" header
        # as it's not supported on the Akamai side.
        [System.Net.ServicePointManager]::Expect100Continue = $false
    }

    # Set TLS version to 1.2
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

    $params = @{
        Method = $Method
        Uri = $ReqURL
        Headers = $Headers
        ContentType =  $ContentType
    }
    
    if ($null -ne $ENV:https_proxy) { $params.Proxy = $ENV:https_proxy }
    if ($null -ne $ENV:proxy_use_default_credentials) { $params.ProxyUseDefaultCredentials = $true }

    if ($Method -in "PUT","POST","PATCH") {
        if ($Body) { $params.Body = $Body }
        if ($InputFile) { $params.InFile = $InputFile }
    }
    
    # GET requests typically
    else { 
        $params.MaximumRedirection = 0

        # Differentiate on PS 5 and later as PS 5's Invoke-RestMethod doesn't behave the same as the later versions
        if ($PSVersionTable.PSVersion.Major -le 5) {
            $params.ErrorAction = "SilentlyContinue"
        }
        else {
            $params.ErrorAction = "Stop"
            $params.ResponseHeadersVariable = $ResponseHeadersVariable
        }
    }

    if($OutputFile){
        $params.OutFile = $OutputFile
    }
    
    try {
        $Response = Invoke-RestMethod @params
    }
    catch {
        # PS >=6 handling
        # Redirects aren't well handled due to signatures needing regenerated
        if ($_.Exception.Response.StatusCode.value__ -eq 301 -or $_.Exception.Response.StatusCode.value__ -eq 302) {
            try {
                $NewPath = $_.Exception.Response.Headers.Location.PathAndQuery
                Write-Debug "Redirecting to $NewPath"
                $Response = Invoke-AkamaiRestMethod -Method $Method -Path $NewPath -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section -ResponseHeadersVariable $ResponseHeadersVariable -AccountSwitchKey $AccountSwitchKey
            }
            catch {
                throw $_
            }
        }
        else {
            throw $_
        }
    }
    
    # PS <5 handling
    if ($null -ne ($Response.PSObject.members | Where-Object { $_.Name -eq "redirectLink" }) -and $method -notin "PUT","POST","PATCH") {
        try {
            Write-Debug "Redirecting to $($Response.redirectLink)"
            $Response = Invoke-AkamaiRestMethod -Method $Method -Path $Response.redirectLink -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        }
        catch {
            throw $_
        }
    }
    
    # Set ResponseHeadersVariable to be passed back to requesting function
    if ($ResponseHeadersVariable) {
        Set-Variable -name $ResponseHeadersVariable -Value (Get-Variable -Name $ResponseHeadersVariable -ValueOnly -ErrorAction SilentlyContinue) -Scope Script
    }
    Return $Response
}

# SIG # Begin signature block
# MIIpogYJKoZIhvcNAQcCoIIpkzCCKY8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBQeYD7JQOM5410
# 1pUwjNsT4hHfPq4WpdOyfW35sRCAV6CCDpEwggawMIIEmKADAgECAhAIrUCyYNKc
# TJ9ezam9k67ZMA0GCSqGSIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNV
# BAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMTA0MjkwMDAwMDBaFw0z
# NjA0MjgyMzU5NTlaMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
# ggIKAoICAQDVtC9C0CiteLdd1TlZG7GIQvUzjOs9gZdwxbvEhSYwn6SOaNhc9es0
# JAfhS0/TeEP0F9ce2vnS1WcaUk8OoVf8iJnBkcyBAz5NcCRks43iCH00fUyAVxJr
# Q5qZ8sU7H/Lvy0daE6ZMswEgJfMQ04uy+wjwiuCdCcBlp/qYgEk1hz1RGeiQIXhF
# LqGfLOEYwhrMxe6TSXBCMo/7xuoc82VokaJNTIIRSFJo3hC9FFdd6BgTZcV/sk+F
# LEikVoQ11vkunKoAFdE3/hoGlMJ8yOobMubKwvSnowMOdKWvObarYBLj6Na59zHh
# 3K3kGKDYwSNHR7OhD26jq22YBoMbt2pnLdK9RBqSEIGPsDsJ18ebMlrC/2pgVItJ
# wZPt4bRc4G/rJvmM1bL5OBDm6s6R9b7T+2+TYTRcvJNFKIM2KmYoX7BzzosmJQay
# g9Rc9hUZTO1i4F4z8ujo7AqnsAMrkbI2eb73rQgedaZlzLvjSFDzd5Ea/ttQokbI
# YViY9XwCFjyDKK05huzUtw1T0PhH5nUwjewwk3YUpltLXXRhTT8SkXbev1jLchAp
# QfDVxW0mdmgRQRNYmtwmKwH0iU1Z23jPgUo+QEdfyYFQc4UQIyFZYIpkVMHMIRro
# OBl8ZhzNeDhFMJlP/2NPTLuqDQhTQXxYPUez+rbsjDIJAsxsPAxWEQIDAQABo4IB
# WTCCAVUwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUaDfg67Y7+F8Rhvv+
# YXsIiGX0TkIwHwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0P
# AQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHcGCCsGAQUFBwEBBGswaTAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAC
# hjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNydDBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNybDAcBgNVHSAEFTATMAcGBWeBDAED
# MAgGBmeBDAEEATANBgkqhkiG9w0BAQwFAAOCAgEAOiNEPY0Idu6PvDqZ01bgAhql
# +Eg08yy25nRm95RysQDKr2wwJxMSnpBEn0v9nqN8JtU3vDpdSG2V1T9J9Ce7FoFF
# UP2cvbaF4HZ+N3HLIvdaqpDP9ZNq4+sg0dVQeYiaiorBtr2hSBh+3NiAGhEZGM1h
# mYFW9snjdufE5BtfQ/g+lP92OT2e1JnPSt0o618moZVYSNUa/tcnP/2Q0XaG3Ryw
# YFzzDaju4ImhvTnhOE7abrs2nfvlIVNaw8rpavGiPttDuDPITzgUkpn13c5Ubdld
# AhQfQDN8A+KVssIhdXNSy0bYxDQcoqVLjc1vdjcshT8azibpGL6QB7BDf5WIIIJw
# 8MzK7/0pNVwfiThV9zeKiwmhywvpMRr/LhlcOXHhvpynCgbWJme3kuZOX956rEnP
# LqR0kq3bPKSchh/jwVYbKyP/j7XqiHtwa+aguv06P0WmxOgWkVKLQcBIhEuWTatE
# QOON8BUozu3xGFYHKi8QxAwIZDwzj64ojDzLj4gLDb879M4ee47vtevLt/B3E+bn
# KD+sEq6lLyJsQfmCXBVmzGwOysWGw/YmMwwHS6DTBwJqakAwSEs0qFEgu60bhQji
# WQ1tygVQK+pKHJ6l/aCnHwZ05/LWUpD9r4VIIflXO7ScA+2GRfS0YW6/aOImYIbq
# yK+p/pQd52MbOoZWeE4wggfZMIIFwaADAgECAhAHzYbPdL0G4DP0mj8QhQwXMA0G
# CSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwHhcNMjMwMTExMDAwMDAwWhcNMjQwMzAy
# MjM1OTU5WjCB3jETMBEGCysGAQQBgjc8AgEDEwJVUzEZMBcGCysGAQQBgjc8AgEC
# EwhEZWxhd2FyZTEdMBsGA1UEDwwUUHJpdmF0ZSBPcmdhbml6YXRpb24xEDAOBgNV
# BAUTBzI5MzM2MzcxCzAJBgNVBAYTAlVTMRYwFAYDVQQIEw1NYXNzYWNodXNldHRz
# MRIwEAYDVQQHEwlDYW1icmlkZ2UxIDAeBgNVBAoTF0FrYW1haSBUZWNobm9sb2dp
# ZXMgSW5jMSAwHgYDVQQDExdBa2FtYWkgVGVjaG5vbG9naWVzIEluYzCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBAKkC2pEjLYnjLtkW+Vkz3mCe+wElX+k7
# AgEtGOL+rqaYNF9CdS8veLyZY6fQeq/ugDkdGuKdz0oXGlzTaVgnOcd1TZrVSeVR
# KiE9/gO1mSP/kuyJPKFMDUNR4LE5+j5chSCyLoKhmsAFdus/KH6ZizjcM4rtTkNs
# 714lHQ91LssdoX+rZXhn/ttsiEtOG4dAZdntDv4aDjI/lde5DouV9k/ISKPTrvmF
# obsrEUxqfOwynq8yqVaQMABw8aeA0ajU6EgD+4gGG8TaFNxQZOPgAZNWYpqwbnlR
# f35mgl4HufEPVaHwN8158jpippKW7iUFTvV5zpmcd6T1DMWtoePcRLm/unvosA0g
# DHn/hZO+GdQ4IbJ70oObq497Xwp02iGP4b/dNHQF3XV92Y262v0c1WkaAVAOHMFP
# nJVp7FAUS2I3Zfqu/R2ZjSUfXPtWg2ar+HGZ4tAnc6Zd5uS+Ggyf5jUA2rz9r0wT
# fxei07j2A1F5/kvpUMevzkEE2aWWeKQrqiSIPT48j2VoMM9zQD3v7tGvzAHk9SSi
# SSOM6NZWwDROdTSXn5pCNzEwfy7OinP33qSZWC1Omx3GNPtHVGcBGOZCwbNBiz2i
# EwR4HyJvuxZjeam5dM5zuuCoyYrxLINVlcLFpbg7uAMaM0WTf52/SB2040aDeSzi
# kVgXUiWy9MnxAgMBAAGjggIFMIICATAfBgNVHSMEGDAWgBRoN+Drtjv4XxGG+/5h
# ewiIZfROQjAdBgNVHQ4EFgQUAgywME/nFo30YHtViHhRyLCj41MwDgYDVR0PAQH/
# BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMIG1BgNVHR8Ega0wgaowU6BRoE+G
# TWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENvZGVT
# aWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3JsMFOgUaBPhk1odHRwOi8vY3Js
# NC5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmluZ1JTQTQw
# OTZTSEEzODQyMDIxQ0ExLmNybDA9BgNVHSAENjA0MDIGBWeBDAEDMCkwJwYIKwYB
# BQUHAgEWG2h0dHA6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzCBlAYIKwYBBQUHAQEE
# gYcwgYQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBcBggr
# BgEFBQcwAoZQaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0MjAyMUNBMS5jcnQwDAYDVR0T
# AQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAqItOsemfwmwzLKUyPRVuyuXhMpWM
# iHQqfsSloP6KdVwtTMQBP1lmxsE1qAQ3R52iCiGAra7dvZRUm3mWXTntXQwXUEqH
# dguy53+VrZ7f+BtZiL51OJOJXyiy3lSA+rrr7g1Xuz2ax+tRLqkmmOswYoPSnSIc
# EhGyaoLKFX19/agk6tiZzVdzbz5N/aPFKAng0BkilTvSI8JJDHyO2lxhHzZ3zPFf
# 51pxBn7+HkeRdLQ2aSy4j8Y8P2sMWPOhs2EjDJ14wHZIPHMHorI40AnPVOQjJ1h1
# ME/eh2HVCQMf1BIDc7ZXkHX6mW6BbLxTuWhxiPcTKvj3/HO+VyeEjTgT0+NHCEiQ
# +LFudP/MYR7T8Vy2Zsg0HnNXAsC2JjDLLu/Ce69Xlh3ntc0jiQtT0X38ZMXwUSA+
# 7jgNe93Wx4GLjzw9MfOXYwqRAWC2dUXcUWKUHGpreX4wRQjemFMifnaEOfWJZZ5w
# mkGJkfh0XmVfFFg4aE6LidoqcKvlXfpzNxEsBTJUeETPdaiYHhJT5M7YgQiAuJd6
# bQj67m/lutkBz5ucXuOSte3wddC4PmFMCkrJ/3ZLk5se0Tcq1+Zxj2IDNXUkO14p
# 0lGr0mLiEBXIJB0/RTdrCNQXTgfBfm/2JGm11XnKxWYr7iRxZwWjh5V/FJYO6kHc
# JZzQBtUCg02o9ogxghpnMIIaYwIBATB9MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQK
# Ew5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBD
# b2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEzODQgMjAyMSBDQTECEAfNhs90vQbgM/Sa
# PxCFDBcwDQYJYIZIAWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG
# 9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIB
# FTAvBgkqhkiG9w0BCQQxIgQgTqiLfxIdj3ISpoIR9ZY8xtJf8l7uy2lx5AaJerdu
# ch8wDQYJKoZIhvcNAQEBBQAEggIACvvfjdCsqFGnpu8gTPJ3AKTUDbz2oU4XHyyq
# gzkBQJyutGYn1sSJgQttzD6P90d+wRXXK464qxhUXQbhvBGduR0nZpJsPlgdJscI
# 50YH0KITk8v6F3JxKEn8up/abXVg713nydOHKXYuvC9n2eLMbmL1ybaPgRrYYJxr
# IP42rXaNeNQv834p0uUNYf4YD1JcxkLWXsE6wmmhEtCgiDyEDNou7Nrdt56G6sq3
# UuesHR49RSwB8l3msKhuTijl4VXhJAarAS2+lkw42sxEwP9hLMKSb4jTuwFGL//o
# uSOE5nG8W8Rha3K3HQZzg3B4o60jRqUMd/sDnJOsS0QxERAIerBfSQnuHBAiWBtD
# voT/dbQ1eNkvY3owimJ77K3NWhE8y71XfNKWxA25lQRcVnAVX4adxxQBrebLhBi5
# g8eH5ofyIIk9v3JiNPgF8VUeO3ZBgRbZLNjzSd0wteLNnaVRYRJgFdGHMGaaLMeu
# 8t3bDySSzQGLKjKKCGwFQPI9bW+h/8ktU2o3C0hwRuCQO/ETb2v02AseSSaodH5a
# 2KeG5R/HbEPeNoGMWLSb/oDZVrMUHIP9za2eNgasKshmJBP3s3mv9yEfi1qkV5oZ
# NvfFRjp6PGjWZNFFdrxZqJe8eUp022LXz5BMgoeP7AS2j/co4d9/d+8Xf7EWs/sd
# bUdFWOahghc9MIIXOQYKKwYBBAGCNwMDATGCFykwghclBgkqhkiG9w0BBwKgghcW
# MIIXEgIBAzEPMA0GCWCGSAFlAwQCAQUAMHcGCyqGSIb3DQEJEAEEoGgEZjBkAgEB
# BglghkgBhv1sBwEwMTANBglghkgBZQMEAgEFAAQgW8Uy0qbByVCh4Hvc/nQfTEYK
# 5zxjvgJ8T57C9zFpUt4CEAFgWOEoj1uwi+1ZLsYWuxQYDzIwMjMwNDI1MTcxOTQ0
# WqCCEwcwggbAMIIEqKADAgECAhAMTWlyS5T6PCpKPSkHgD1aMA0GCSqGSIb3DQEB
# CwUAMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkG
# A1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3Rh
# bXBpbmcgQ0EwHhcNMjIwOTIxMDAwMDAwWhcNMzMxMTIxMjM1OTU5WjBGMQswCQYD
# VQQGEwJVUzERMA8GA1UEChMIRGlnaUNlcnQxJDAiBgNVBAMTG0RpZ2lDZXJ0IFRp
# bWVzdGFtcCAyMDIyIC0gMjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AM/spSY6xqnya7uNwQ2a26HoFIV0MxomrNAcVR4eNm28klUMYfSdCXc9FZYIL2tk
# pP0GgxbXkZI4HDEClvtysZc6Va8z7GGK6aYo25BjXL2JU+A6LYyHQq4mpOS7eHi5
# ehbhVsbAumRTuyoW51BIu4hpDIjG8b7gL307scpTjUCDHufLckkoHkyAHoVW54Xt
# 8mG8qjoHffarbuVm3eJc9S/tjdRNlYRo44DLannR0hCRRinrPibytIzNTLlmyLuq
# UDgN5YyUXRlav/V7QG5vFqianJVHhoV5PgxeZowaCiS+nKrSnLb3T254xCg/oxwP
# UAY3ugjZNaa1Htp4WB056PhMkRCWfk3h3cKtpX74LRsf7CtGGKMZ9jn39cFPcS6J
# AxGiS7uYv/pP5Hs27wZE5FX/NurlfDHn88JSxOYWe1p+pSVz28BqmSEtY+VZ9U0v
# kB8nt9KrFOU4ZodRCGv7U0M50GT6Vs/g9ArmFG1keLuY/ZTDcyHzL8IuINeBrNPx
# B9ThvdldS24xlCmL5kGkZZTAWOXlLimQprdhZPrZIGwYUWC6poEPCSVT8b876asH
# DmoHOWIZydaFfxPZjXnPYsXs4Xu5zGcTB5rBeO3GiMiwbjJ5xwtZg43G7vUsfHuO
# y2SJ8bHEuOdTXl9V0n0ZKVkDTvpd6kVzHIR+187i1Dp3AgMBAAGjggGLMIIBhzAO
# BgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEF
# BQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0jBBgw
# FoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFGKK3tBh/I8xFO2XC809
# KpQU31KcMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5j
# cmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdD
# QS5jcnQwDQYJKoZIhvcNAQELBQADggIBAFWqKhrzRvN4Vzcw/HXjT9aFI/H8+ZU5
# myXm93KKmMN31GT8Ffs2wklRLHiIY1UJRjkA/GnUypsp+6M/wMkAmxMdsJiJ3Hjy
# zXyFzVOdr2LiYWajFCpFh0qYQitQ/Bu1nggwCfrkLdcJiXn5CeaIzn0buGqim8FT
# YAnoo7id160fHLjsmEHw9g6A++T/350Qp+sAul9Kjxo6UrTqvwlJFTU2WZoPVNKy
# G39+XgmtdlSKdG3K0gVnK3br/5iyJpU4GYhEFOUKWaJr5yI+RCHSPxzAm+18SLLY
# kgyRTzxmlK9dAlPrnuKe5NMfhgFknADC6Vp0dQ094XmIvxwBl8kZI4DXNlpflhax
# YwzGRkA7zl011Fk+Q5oYrsPJy8P7mxNfarXH4PMFw1nfJ2Ir3kHJU7n/NBBn9iYy
# mHv+XEKUgZSCnawKi8ZLFUrTmJBFYDOA4CPe+AOk9kVH5c64A0JH6EE2cXet/aLo
# l3ROLtoeHYxayB6a1cLwxiKoT5u92ByaUcQvmvZfpyeXupYuhVfAYOd4Vn9q78KV
# mksRAsiCnMkaBXy6cbVOepls9Oie1FqYyJ+/jbsYXEP10Cro4mLueATbvdH7Wwqo
# cH7wl4R44wgDXUcsY6glOJcB0j862uXl9uab3H4szP8XTE0AotjWAQ64i+7m4HJV
# iSwnGWH2dwGMMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkqhkiG
# 9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkw
# FwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVz
# dGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5WjBjMQsw
# CQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRp
# Z2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENB
# MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1BkmzwT1ySVFVxyUD
# xPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkLf50fng8zH1AT
# CyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO6lE98NZW
# 1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5n12sy+iEZLRS
# 8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYNXNXmG6jB
# ZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWHpo9OdhVVJnCY
# Jn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7jPqJz+ucf
# WmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/8KI8ykLc
# GEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixXNXkrqPNF
# YLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mMDDtbiiKowSYI
# +RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O6V3IXjAS
# vUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYBAf8C
# AQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1UdIwQYMBaAFOzX
# 44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggr
# BgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3Nw
# LmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4oDag
# NIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RH
# NC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3
# DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y+8dQXeJL
# Kftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExiHQwIgqgW
# valWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye4Iqs5f2M
# vGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj+sAngkSu
# mScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8THwcFqcdnGE4AJ
# xLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZJyw9P2un
# 8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9Pzt4rUyt+8SV
# e+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm228Vex4Ziza4
# k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVBtzrVFZgxtGIJ
# Dwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnwZXZCpimHCUcr
# 5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv27dZ8/DCCBY0w
# ggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEMBQAwZTELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENB
# MB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkGA1UEBhMCVVMx
# FTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNv
# bTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zCpyUuySE98orY
# WcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf1gU8Ug9SH8ae
# FaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x4i0MG+4g1ckg
# HWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEioZldXn1RYjgwr
# t0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7axxLVqGDgDEI3Y
# 1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZOjFEmjNAvwjX
# WkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJl2l6SPDgohIb
# Zpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz2cXfSwQAzH0c
# lcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH4b235kOkGLim
# dwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb5RBQ6zHFynIW
# IgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ9eRpL5gdLfXZ
# qbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFOzX
# 44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3z
# bcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGG
# GGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2Nh
# Y2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDBF
# BgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0gADANBgkqhkiG
# 9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs7IVeqRq7IviH
# GmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq3votVs/59Pes
# MHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/Lwum6fI0POz3
# A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9/HYJaISfb8rb
# II01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWojayL/ErhULSd+
# 2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDGCA3YwggNyAgEBMHcwYzELMAkG
# A1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdp
# Q2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQQIQ
# DE1pckuU+jwqSj0pB4A9WjANBglghkgBZQMEAgEFAKCB0TAaBgkqhkiG9w0BCQMx
# DQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTIzMDQyNTE3MTk0NFowKwYL
# KoZIhvcNAQkQAgwxHDAaMBgwFgQU84ciTYYzgpI1qZS8vY+W6f4cfHMwLwYJKoZI
# hvcNAQkEMSIEIKxVmGeaSyVKlqHWwQ8+0LnEtZoJwjeXwkfJl2n4vyzcMDcGCyqG
# SIb3DQEJEAIvMSgwJjAkMCIEIMf04b4yKIkgq+ImOr4axPxP5ngcLWTQTIB1V6Aj
# tbb6MA0GCSqGSIb3DQEBAQUABIICAEsnt/w/S+C9ZmQGHnrsSj6Tf23Axn6oeBaE
# JdQEdOEqAWZICIJRLh6DYh3vAA92EleUYD/MoH2VlRjk8jGX/S1vC0NRNWcXGA0Q
# 2O0kt7y8ckyxJw7nB9ziEuSf0/FNsVdS6RZspInFETMCvZXBKDhLjHomiVpOPuMH
# IZ6sC2txnfb+arsJoQ5444aBdg+Y+FxnsahcgBChWwevBpz0cixTmWaabLD/70c4
# PItCT4YSNRvHyNVZ0FtPgEzOkr0z/XdYrySVpGuoyzP9aV22Mm66WZdbviJT/IMt
# 89iFLzWXuqYPLKZpyqV5HAgyYyPIxfVIWKwHaM00L39Hhhj6Ze4cjxBDvNDWHE4q
# jTA8YdhbPYJ5uPG0h3mm/Z9UlPPjtHIS+d3I0X3qFkv83W98/XXtsJidN/KlxW4v
# ERjQGdPtro/GXgqHGY+5sTMDDZwpwIlc8TXDtKPuihxAEM3oD7+wg77rannauCTa
# /4p3uwrrWwqFXbQGtpakrmddtXw8cqeTPcH/bA/DWgS7X69KNO7wh8MFeHBTUY1F
# fNR+OGdPtOvBkOla6vzKanBLw2mhmfGT/AWhC/DOtHgz0m5v8y6k5msDBQ0SFHiB
# Xc5JDq/qtp0zZnggCt0M8rivfApQ6OrET7AO13lAad41oi0Y2jme47ds/hL1bdnM
# sNve7K+P
# SIG # End signature block
