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
Remove existing Akamai session object
.DESCRIPTION
Variable is deleted
.EXAMPLE
Remove-AkamaiSession
.LINK
techdocs.akamai.com
#>
Function Remove-AkamaiSession {
    try{
        $Var = Get-Variable -Name AkamaiSession -Scope Script
        $Exists = $true
    }
    catch{
        $Exists = $False
    }
    if($Exists){
        Remove-Variable -Name AkamaiSession -Scope Script
        Write-Host 'Session removed'
    }
}
