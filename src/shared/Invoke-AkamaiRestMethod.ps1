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
    if ($Debug) {
        ## Check creds if in Debug mode
        Test-Auth -Auth $Auth
    }

    # Add account switch key from $Auth, if present
    if ($Auth.account_key) {
        if ($Path.Contains('?')) { $Path += '&' }
        else { $Path += '?' }
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
                $Body_Hash = [System.Convert]::ToBase64String($Body_SHA256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Body.Substring(0, $MaxBody))))
            }
            else {
                $Body_Hash = [System.Convert]::ToBase64String($Body_SHA256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Body)))
            }

            $SignatureData += "`t`t" + $Body_Hash + "`t"
        }
        elseif ($InputFile) {
            $Body_SHA256 = [System.Security.Cryptography.SHA256]::Create()
            if ($PSVersionTable.PSVersion.Major -le 5) {
                $Bytes = Get-Content $InputFile -Encoding Byte
            }
            else {
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
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        #< 6 is missing the OS member of PSVersionTable, so we use env variables
        $UserAgent = "AkamaiPowershell/$($Env:AkamaiPowershellVersion) (Powershell $PSEdition $($PSVersionTable.PSVersion) $PSCulture, $($PSVersionTable.OS))"
    }
    else {
        $UserAgent = "AkamaiPowershell/$($Env:AkamaiPowershellVersion) (Powershell $PSEdition $($PSVersionTable.PSVersion) $PSCulture, $($Env:OS))"
    }
    
    # Add headers
    $Headers.Add('Authorization', $AuthorizationHeader)
    $Headers.Add('Accept', 'application/json')
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

    # turn off the "Expect: 100 Continue" header
    # as it's not supported on the Akamai side.
    [System.Net.ServicePointManager]::Expect100Continue = $false

    # Set TLS version to 1.2
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

    $params = @{
        Method             = $Method
        Uri                = $ReqURL
        Headers            = $Headers
        ContentType        = $ContentType
        MaximumRedirection = 0
    }
    
    if ($null -ne $ENV:https_proxy) { $params.Proxy = $ENV:https_proxy }
    if ($null -ne $ENV:proxy_use_default_credentials) { $params.ProxyUseDefaultCredentials = $true }

    # Add -AllowInsecureRedirect if Pwsh 7.4 or higher
    if ($PSVersionTable.PSVersion.Major -gt 7 -or ($PSVersionTable.PSVersion.Major -eq 7 -and $PSVersionTable.PSVersion.Minor -ge 4)) {
        $params.AllowInsecureRedirect = $true
    }

    if ($Method -in "PUT", "POST", "PATCH") {
        if ($Body) { $params.Body = $Body }
        if ($InputFile) { $params.InFile = $InputFile }
    }
    # GET requests typically
    else { 
        # Differentiate on PS 5 and later as PS 5's Invoke-RestMethod doesn't behave the same as the later versions
        if ($PSVersionTable.PSVersion.Major -le 5) {
            $params.ErrorAction = "SilentlyContinue"
        }
        else {
            $params.ErrorAction = "Stop"
            $params.ResponseHeadersVariable = $ResponseHeadersVariable
        }
    }

    if ($OutputFile) {
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
    if ($null -ne ($Response.PSObject.members | Where-Object { $_.Name -eq "redirectLink" }) -and $method -notin "PUT", "POST", "PATCH") {
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
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAKiVzxHOoSLcyQ
# tJLVuBaHPPbdf0GIJ2/jr8+Fc1CoKqCCDo4wggawMIIEmKADAgECAhAIrUCyYNKc
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
# yK+p/pQd52MbOoZWeE4wggfWMIIFvqADAgECAhAByZH9J50Asj/oHHbeHclzMA0G
# CSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwHhcNMjMwNjEzMDAwMDAwWhcNMjQwMzAy
# MjM1OTU5WjCB3jETMBEGCysGAQQBgjc8AgEDEwJVUzEZMBcGCysGAQQBgjc8AgEC
# EwhEZWxhd2FyZTEdMBsGA1UEDwwUUHJpdmF0ZSBPcmdhbml6YXRpb24xEDAOBgNV
# BAUTBzI5MzM2MzcxCzAJBgNVBAYTAlVTMRYwFAYDVQQIEw1NYXNzYWNodXNldHRz
# MRIwEAYDVQQHEwlDYW1icmlkZ2UxIDAeBgNVBAoTF0FrYW1haSBUZWNobm9sb2dp
# ZXMgSW5jMSAwHgYDVQQDExdBa2FtYWkgVGVjaG5vbG9naWVzIEluYzCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBANdcrYnd5Y2q/LVByT4/w8A8XsvNZyET
# aJPcPw3DKpswy7TCGFLdVd5sD923zWlXy5VmXqYB/QQ1+yPjgSdgxiOFuhxL8tll
# 8OSb6auUUyrnIXx4PbcDAOKfd9J0IkQuBGNZvnMom9DkxTEpunaLEqjVFo08i53H
# 4VNmPgr7//qbEBCCulDYAg6K6HV7vckP/dTwqJ17jP3Qw0N8rnjcoxf6AwuuKcxl
# lQ4Zdr9q1yYUkvuAw6I5Vw78ODwb1Q+/nK+rYMY+Lx4W7YeAsvAXKWlUE5AXLgVC
# 3N7Xa5ZtAsaLzXJIcqW3HhCEWTygP0lTaPN9CIMnQqLtbve1PVaHH4bXG8hV9kuR
# hT5ZjvVGPDAJ9+xZap9AV+oVNp7QcbQ/p4r104TDGMA2j1wGUmRBcZobo2ypOREd
# jaI4xymenRenRhnxuAdU6Vm3yYam6XiWrIJszEk0i23bFs6wDy5wSPqr11lxn3Zh
# ksb04q+UvU+IhNkStSfwS5wizLA/KSuUjBkU7+sEd5lJaFEHHj3sH192ajODOi4s
# 3empeuwFjZbWukcq8fTLHiTkhyPoPgjvYq+6l0pZdH48pZA6utqMDO/0xIHl+PAy
# oQDVZgufYvvzsAGGF7cyFRyS7F/Tprxbd11w8DNv9I0MR+1zCMRPldAQ4aMYEakI
# kSHYuPZjXWVnAgMBAAGjggICMIIB/jAfBgNVHSMEGDAWgBRoN+Drtjv4XxGG+/5h
# ewiIZfROQjAdBgNVHQ4EFgQU4lrKPnD2cLwdOGv6x3R0iO+5q64wDgYDVR0PAQH/
# BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMIG1BgNVHR8Ega0wgaowU6BRoE+G
# TWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENvZGVT
# aWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3JsMFOgUaBPhk1odHRwOi8vY3Js
# NC5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmluZ1JTQTQw
# OTZTSEEzODQyMDIxQ0ExLmNybDA9BgNVHSAENjA0MDIGBWeBDAEDMCkwJwYIKwYB
# BQUHAgEWG2h0dHA6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzCBlAYIKwYBBQUHAQEE
# gYcwgYQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBcBggr
# BgEFBQcwAoZQaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0MjAyMUNBMS5jcnQwCQYDVR0T
# BAIwADANBgkqhkiG9w0BAQsFAAOCAgEA0yVWE59ZytC1egGLlmnUVBJk6TmpFZ2s
# dl8UtpZvb8YvDM105QhMGPtnEd4ffoqPqvgQwU7GZe7ZXrWxUu0C/ui5R5sp0fFI
# eahFBPc7cfz54jD/z+AIYDmw+Q/RgFCkAY9N2OF1KNjssKhj6cd6Z7aSc3Zj7FG3
# crXhXAmUWVosvFunEKkHXWXYbpv8edv8FC8ASvVUmVqdrHaXXSS8HigZEh/HE+XK
# A+CbBy2vQvwHq12brc7tkpSk6r15aG+RRdWmP8BirKeNYOzMZNP3XcgemmaK1SjO
# jOw/A3zyQXNEaDiAULvze1gtf8r6WT/nItgthpvKQhFejNhaAaBqlrS1YbOSvTtK
# CZMsKSTb+DEbN0dG/wcnJ4vWk4dOrgdgIDpNBhPy7q7l1v+woOWRH5UJsGNq0oFn
# wxOEdKYJ5Qn+5EMw++NMax1VlJaRrDL1nTPJudpuhpf1h1JOPhiNBsJHtCJXcxX/
# n6SUpn/VR+6Y0Lx/Knii2f8wZRFd8pCbnDLlQbwR1AxlGbQ9FlICmy+rIk+gHXC4
# 7P2JRO6uOBQcbwQDFUFC882CtKHhUtveU39LUBzkhPBByqx0e1ACcUyRIMwj4pC1
# ZS6sTPp622OBbsv0NKXZIpaSdcsF7Lak56ZQwHlO9tUDKm9KzVQHrp2v/0tdv9cz
# moABt8TK7rsxghpqMIIaZgIBATB9MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5E
# aWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2Rl
# IFNpZ25pbmcgUlNBNDA5NiBTSEEzODQgMjAyMSBDQTECEAHJkf0nnQCyP+gcdt4d
# yXMwDQYJYIZIAWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0B
# CQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAv
# BgkqhkiG9w0BCQQxIgQgFy0FhvAuJKuAEH2D7z/G3f2b+brhyEcWVh6QKxvSg/8w
# DQYJKoZIhvcNAQEBBQAEggIAisIZRyzF6ttAnzyhEF6QTfue9wKC+s/55BRA93QZ
# PVjgRUUJ6DIxMJ+uFMLkWvTcLprT5GFO2EruMn0waeGYS9CgjMXTQXV5Fi9ERWmQ
# gF3GxzfU04m590Rnxf2iuGz2Ikt+Vojg/3H6vjEQp8lq94ILIE6EbKNb7O3jwZlc
# 6EU5r5zFfDxifl64lQj31H5VKgGqi3mQ5o8RrPBlJarT90scSISjRKyebahG7i6K
# 7e9DPxXtnoTIPqNWwWkzb8B7XUYm1XfHgzfqVsro6nfeEiEhMRuOnCM7+m1FPLLp
# KY89lE/Ex+j1PBaj7KTQP5Pzv9ZIPoC7SVqyFKoN5/bOH5G+j0Op4fAiwkrxGHvd
# mECrhcbCbQPC5UUdX8yI9jjSvJw/QpHfVbCNkYERAiSLh5cJ8VXnquNvhuLR3TQV
# 4hB+0G6M1NjOV4eBlnQDGB45MqPDshQjHINfARe6+RJjL1oPBJGJX2+hNmT/GnW8
# eBxI3dgDe1DEnuh2FdJt/TNoCMC4VrxxB5WyCXd1WepdOshFmnxRkEv2Id5r4pRX
# te3ru32P7mXBQsuxwkcO0L7GsVwd1W8fu4l4xB80xMgAoD3+7+rJK4F6tUHZgBxQ
# PB4Tt8GA4uwVlVYZN+1gkIpzcAu3V07XMySjB5xavQv3OjekaM3q29Dd/bOd4z7J
# Mo+hghdAMIIXPAYKKwYBBAGCNwMDATGCFywwghcoBgkqhkiG9w0BBwKgghcZMIIX
# FQIBAzEPMA0GCWCGSAFlAwQCAQUAMHgGCyqGSIb3DQEJEAEEoGkEZzBlAgEBBglg
# hkgBhv1sBwEwMTANBglghkgBZQMEAgEFAAQg1BjEggVoLpwBF5X613/ri6Lz+Crn
# A3YcQmyO+DQBVV0CEQDjK5SwPa5fOiSb8c6CcAtOGA8yMDIzMTEwNjE3MTU1NFqg
# ghMJMIIGwjCCBKqgAwIBAgIQBUSv85SdCDmmv9s/X+VhFjANBgkqhkiG9w0BAQsF
# ADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNV
# BAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1w
# aW5nIENBMB4XDTIzMDcxNDAwMDAwMFoXDTM0MTAxMzIzNTk1OVowSDELMAkGA1UE
# BhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSAwHgYDVQQDExdEaWdpQ2Vy
# dCBUaW1lc3RhbXAgMjAyMzCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AKNTRYcdg45brD5UsyPgz5/X5dLnXaEOCdwvSKOXejsqnGfcYhVYwamTEafNqrJq
# 3RApih5iY2nTWJw1cb86l+uUUI8cIOrHmjsvlmbjaedp/lvD1isgHMGXlLSlUIHy
# z8sHpjBoyoNC2vx/CSSUpIIa2mq62DvKXd4ZGIX7ReoNYWyd/nFexAaaPPDFLnkP
# G2ZS48jWPl/aQ9OE9dDH9kgtXkV1lnX+3RChG4PBuOZSlbVH13gpOWvgeFmX40Qr
# StWVzu8IF+qCZE3/I+PKhu60pCFkcOvV5aDaY7Mu6QXuqvYk9R28mxyyt1/f8O52
# fTGZZUdVnUokL6wrl76f5P17cz4y7lI0+9S769SgLDSb495uZBkHNwGRDxy1Uc2q
# TGaDiGhiu7xBG3gZbeTZD+BYQfvYsSzhUa+0rRUGFOpiCBPTaR58ZE2dD9/O0V6M
# qqtQFcmzyrzXxDtoRKOlO0L9c33u3Qr/eTQQfqZcClhMAD6FaXXHg2TWdc2PEnZW
# pST618RrIbroHzSYLzrqawGw9/sqhux7UjipmAmhcbJsca8+uG+W1eEQE/5hRwqM
# /vC2x9XH3mwk8L9CgsqgcT2ckpMEtGlwJw1Pt7U20clfCKRwo+wK8REuZODLIivK
# 8SgTIUlRfgZm0zu++uuRONhRB8qUt+JQofM604qDy0B7AgMBAAGjggGLMIIBhzAO
# BgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEF
# BQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0jBBgw
# FoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFKW27xPn783QZKHVVqll
# MaPe1eNJMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5j
# cmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdD
# QS5jcnQwDQYJKoZIhvcNAQELBQADggIBAIEa1t6gqbWYF7xwjU+KPGic2CX/yyzk
# zepdIpLsjCICqbjPgKjZ5+PF7SaCinEvGN1Ott5s1+FgnCvt7T1IjrhrunxdvcJh
# N2hJd6PrkKoS1yeF844ektrCQDifXcigLiV4JZ0qBXqEKZi2V3mP2yZWK7Dzp703
# DNiYdk9WuVLCtp04qYHnbUFcjGnRuSvExnvPnPp44pMadqJpddNQ5EQSviANnqlE
# 0PjlSXcIWiHFtM+YlRpUurm8wWkZus8W8oM3NG6wQSbd3lqXTzON1I13fXVFoaVY
# JmoDRd7ZULVQjK9WvUzF4UbFKNOt50MAcN7MmJ4ZiQPq1JE3701S88lgIcRWR+3a
# EUuMMsOI5ljitts++V+wQtaP4xeR0arAVeOGv6wnLEHQmjNKqDbUuXKWfpd5OEhf
# ysLcPTLfddY2Z1qJ+Panx+VPNTwAvb6cKmx5AdzaROY63jg7B145WPR8czFVoIAR
# yxQMfq68/qTreWWqaNYiyjvrmoI1VygWy2nyMpqy0tg6uLFGhmu6F/3Ed2wVbK6r
# r3M66ElGt9V/zLY4wNjsHPW2obhDLN9OTH0eaHDAdwrUAuBcYLso/zjlUlrWrBci
# I0707NMX+1Br/wd3H3GXREHJuEbTbDJ8WC9nR2XlG3O2mflrLAZG70Ee8PBf4NvZ
# rZCARK+AEEGKMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkqhkiG
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
# BUSv85SdCDmmv9s/X+VhFjANBglghkgBZQMEAgEFAKCB0TAaBgkqhkiG9w0BCQMx
# DQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTIzMTEwNjE3MTU1NFowKwYL
# KoZIhvcNAQkQAgwxHDAaMBgwFgQUZvArMsLCyQ+CXc6qisnGTxmcz0AwLwYJKoZI
# hvcNAQkEMSIEIAw0F2fYdj0Sj7yjxcHe7r4SJTjtdTUY+rXHTfPZuCeVMDcGCyqG
# SIb3DQEJEAIvMSgwJjAkMCIEINL25G3tdCLM0dRAV2hBNm+CitpVmq4zFq9NGprU
# DHgoMA0GCSqGSIb3DQEBAQUABIICAA7ceBvkFj8ss1haGP5oYVkF+OpUfJlA/m7i
# 2SWRcEGJmc5100W2d6Ap3PR34MFafjKni39BrkX9zvjKsacQcwNz+iFaOJ3Qvp3E
# ca0XMTLp2P+gEKjZNeDkjldHWjVdMt9VGMQiXEzQCKJ+we4eWN7zApAI5LsC30ou
# fe02q2ddB4A9p7bMHVO/FvpZNNxGCcfunEJCD0wfWWiHIFdIe0nBjlkbHk7XFdyg
# R14nDuKfREhExNEOEgQEn+oHLiqBv6kfHvAs7gJQIRAjsv19YXb0gaLTWm5Rj5pE
# T4nyZYitj27oYkXt4F9kl7qdL//qmMXfZkRiVG88mjeHhc6WuRQs/Y9frYzgYI0a
# HVZZs1zd6mbmlbSQE+QhUVFBr/xo1IR9jIEKyzqCJ2gNL9p6LsxlmEEWNumwC3tq
# +nGysPhC32LHYJazM9zTfWpv9f8MoVpyt+JZpDBIKZ8cpQJsYmcdzcnnSMlATlw9
# 6qTI27m/Moavy0ZFmzxQaky0oWduwQdMUJ1kV/0lGhEwSI+k8PvooGhZ44jFSAGZ
# uh6kUQit5+aeL0JlHDfgmguKOYSHjCqWnMjS7i0+YsS1e5ixZNm5uBqY9a6msbSZ
# WpaewaQK+9aBo1jEk6hzz+hcQsBZVGS2TKTv3IAAE4FeN+7/+bLn2CWvBa6PO+5O
# 0lcmaIzf
# SIG # End signature block
