# Akamai Powershell

This module is designed to abstract the sometimes complex Akamai {OPEN} API commands, and their auth in particular. It can be used in Powershell 5.x or later (6+ is recommended), and there is no reason it won't work on MacOS or Linux, though these are also currently outside the scope of testing. It is in no way complete, but rather is meant to be a collaborative effort to provide Powershell implementation of most (if not all) Akamai APIs. Pull requests are welcome, and encouraged!

The central function of the module is Invoke-AkamaiRestMethod, which is a heavily modified version of the deprecated Invoke-AkamaiOpen you can find [here](https://github.com/akamai/AkamaiOPEN-edgegrid-powershell).

_Note: NO WARRANTY of any kind is offered, or should be inferred. These APIs are very powerful and this module will do little beyond basic syntax checking and will not prevent you doing unspeakable things to your infrastructure if you instruct it to do so._

### Usage

1. Create and populate your .edgerc file in accordance with Akamai recommendations [here](https://developer.akamai.com/legacy/introduction/Conf_Client.html) though I would recommend skipping the Python script and just writing the .edgerc file manually.
2. Install with command `Install-Module AkamaiPowershell` and accept the prompt
3. Import the module using command `Import-Module AkamaiPowershell`

### Getting Started

The module contains hundreds of functions from 30+ APIs, so there is a lot included. Here are some tips to help you:

-   All functions for a given API should contain the same keyword, which you can filter a `Get-Command` command with. For example, all Property API commands contain the word "Property" so you could list the relevant commands by typing `Get-Command *Property* -Module AkamaiPowershell`
-   Functions generally use standard Powershell verbs, with a few notable exceptions. Typically the commands break down like this
    -   `List-` functions list the assets you wish. You can use `List-` or `Get-` interchangeably, so long as the suffix is unchanged (it is generally plural) as each `List-` function has a `Get-` alias
    -   `Get-` (when singular, e.g. `Get-Property`) will find a single entity of an asset, and typically requires that asset's Name or ID. Name support is included in several APIs so you can issue commands such as `Get-Property -PropertyName MyProperty` without knowing the ID in advance
    -   If your command requires a version number, `Property`, `Cloudlet` and `AppSec` APIs allow for the word 'latest' for version. e.g. `Get-AppSecConfigurationVersion -ConfigName MyConfig -VersionNumber latest`
    -   `New-` functions create new assets, or versions. `Remove-` functions delete assets and `Set-` functions perform updates
    -   Many functions support pipelining. For example you might get the rules for a property with the command `$Rules = Get-PropertyRuleTree -PropertyName MyProperty -PropertyVersion latest`, then update an option on the `$Rules` object. Then when you are ready you can issue `$Rules | Set-PropertyRuleTree -PropertyName MyProperty -PropertyVersion latest`, which you will notice is exactly the same as the `Get-` command, but with only 2 characters changed.
-   If you need help with syntax you can use autocomplete or `Get-Help My-Function`. Detailed Help documentation has not yet been included but the `Get-Help` command will list the available options and which ones are required.
-   Whether installing the module via `Install-Module` or cloning this repo you will have access to the source code. If you can't figure out how a function works then it should be a simple matter to find the .ps1 file on disk and open it in your IDE. Most functions are very simple and shouldn't require much expertise to diagnose, and each function has its own file so most are quite short.

### Proxy Support

If you wish to use an https proxy with your commands, simply set the _https_proxy_ environment variable to your proxy address (e.g. http://localhost:8888). Once complete set the variable back to $null. Remember that this var might be persistent so could cause odd behaviors if left in place and the proxy disabled.

### Contribution

If you find there are functions missing (and there are many missing) please contribute to the module, following these recommendations

1. All functions must be (where practical) single-use functions, not multi-function scripts. If you wish to write complex scripts, great, but keep this module to just building blocks.
2. All functions take optional parameters for your .edgerc file and the section to read from. The default is always ~/.edgerc, and the default section 'default'. Entering the credential attributes as individual params is currently not supported, and would be a hassle to implement.
3. All functions must support AccountSwitchKey params. This is a feature only used by Partners and Akamai internal users, but keeps the function universally usable.
4. Please use approved Powershell verbs where applicable. The use of List is fine, as are others when the approved verb would be confusing (like deleting or invalidating from cache. 'removing' isn't really a thing)
5. Please arrange functions into folders based on the name of the API as Akamai have stated it (see the existing folder structure for examples)
6. Update functions (POST/PUT) should have a $Body param for the user to specify the JSON body for the request or an -InputFile param to specify body from a file. If you also wish to allow users to specify individual params and construct the request in the function, that is fine, but make sure the JSON body and individual params are in different Parameter Sets to avoid confusion. Check New-PropertyVersion for an example
7. Similarly to 6. include a pipeline option for any New- or Set- functions. This requires begin/process/end code blocks and param options

### Licensing

Copyright 2019 Akamai Technologies

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
