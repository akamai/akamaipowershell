#Requires -Version 3.0
<#
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

  Author: Brant Peery
  Senior Software Engineer
  Venafi, Inc
#>

<#
.SYNOPSIS
Creates a new Akamai Session info variable in the Script scope 
.DESCRIPTION
Creates a new Akamai Session info variable for use in the authorization scheme for Akamai web calls made by Invoke-AkamaiRestMethod
.Parameter ClientSecret
The client secret
.Parameter Host
The host address for the api endpoints
.Parameter AccessToken
The access token that will be used to access the API endpoints
.Parameter ClientToken
The client token given when the access token was created
.Parameter Environment
Alias = Section
The environment that the authorization information is used for. Default is 'default'
.Parameter Passthrough
Including this switch will return the session variable instead of set the Script scope session variable
.Parameter EdgeRCJSON
Loads the section and auth info from this file instead of individual parameters. Multiple sections can be included.
Example:
{
    "default":{
        "ClientSecret":"yoursecretgoeshere",
        "Host":"your.specific.host.luna.akamaiapis.net",
        "ClientAccessToken":"your-access-token-here",
        "ClientToken":"your-client-token-here"
    }
}
.EXAMPLE
New-AkamaiSession `
   -ClientSecret 38Vx5gv4BESTyj5nTWrJtK9zAknruJmDWfu74TgAgFg=
   -HostName akab-sadfiud8f9s23d-kjieknsod9e8ns1.luna.akamaiapis.net
   -AccessToken akab-xi6ah7ewe2ae5zbk-doiasdnsdf909da
   -ClientToken akab-opsdkenficn2lm3m-9idnowidmsaoem1
.LINK
developer.akamai.com
#>
Function New-AkamaiSession {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Individual")] [string] $ClientSecret,
        [Parameter(Mandatory = $true, ParameterSetName = "Individual")] [string] $HostName,
        [Parameter(Mandatory = $true, ParameterSetName = "Individual")] [string] $ClientAccessToken,
        [Parameter(Mandatory = $true, ParameterSetName = "Individual")] [string] $ClientToken,
        [Parameter(Mandatory = $false, ParameterSetName = "Individual")]
        [Alias("Section")] [string] $Environment = "default",
        [Parameter(Mandatory = $true, ParameterSetName = "json")] [string] $EdgeRCJSON,
        [Parameter()] [switch] $Passthrough
    )
    if ($EdgeRCJSON) { #Use the json string to configure the session
        $AuthInfo = ConvertFrom-Json $EdgeRCJSON

        # Validate auth contents and structure
        if ($null -eq $AuthInfo.PSObject.Properties) {
            throw "Error: At least one config section must be present in the authentication JSON"
        }
        foreach ($p in $AuthInfo.PSObject.Properties) {
            $AuthSection = $p.Value
            if ($null -eq $AuthSection.ClientToken -or $null -eq $AuthSection.ClientAccessToken -or $null -eq $AuthSection.ClientSecret -or $null -eq $AuthSection.Host) {
                throw "Error: Some necessary auth elements missing from the auth section. Please check your EdgeRC JSON"
            }
        }
    }
    else { #Use the individually supplied creds and section name
        $AuthInfo = @{ $Environment = @{
                ClientToken       = $ClientToken
                ClientAccessToken = $AccessToken
                Host              = $HostName
                ClientSecret      = $ClientSecret
            }
        }
    }
    #Return the object if passthrough is present. Otherwise set the script variable
    if ($Passthrough.IsPresent) {
        return @{Auth = $AuthInfo}
    }
    else {
        if (-not ($Script:AkamaiSession -and $Script:AkamaiSession.GetType().Name -eq "Hashtable")) {
            $Script:AkamaiSession = @{}
        }
        if ($Script:AkamaiSession.Auth -eq $null) {
            $Script:AkamaiSession.Auth = @{}
        }
        $Script:AkamaiSession.Auth = $authInfo
    }
}