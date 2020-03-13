# Akamai Powershell

This module is designed to abstract the sometimes complex Akamai {OPEN} API commands, and their auth in particular. It can be used in Powershell 5.x or later (6+ is recommended), and there is no reason it won't work on MacOS or Linux, though these are also currently outside the scope of testing. It is in no way complete, but rather is meant to be a collaborative effort to provide Powershell implementation of most (if not all) Akamai APIs. Pull requests are welcome, and encouraged!

The central function of the module is Invoke-AkamaiRestMethod, which is a heavily modified version of the deprecated Invoke-AkamaiOpen you can find [here](https://github.com/akamai/AkamaiOPEN-edgegrid-powershell).

*Note: NO WARRANTY of any kind is offered, or should be inferred. These APIs are very powerful and this module will do little beyond basic syntax checking and will not prevent you doing unspeakable things to your infrastructure if you instruct it to do so.*

### Usage

1. Create and populate your .edgerc file in accordance with Akamai recommendations [here](https://developer.akamai.com/legacy/introduction/Conf_Client.html) though I would recommend skipping the Python script and just writing the .edgerc file manually.
2. Clone the repo to your local disk
3. Import the module using the standard command `Import-Module path/to/module/AkamaiPowershell.psm1`

### Proxy Support

If you wish to use an https proxy with your commands, simply set the *https_proxy* environment variable to your proxy address (e.g. http://localhost:8888). Once complete set the variable back to $null. Remember that this var might be persistent so could cause odd behaviours if left in place and the proxy disabled.

### Contribution

If you find there are functions missing (and there are many missing) please contribute to the module, following these recommendations

1. All functions must be (where practical) single-use functions, not multi-function scripts. If you wish to write complex scripts, great, but keep this module to just building blocks.
2. All functions take optional parameters for your .edgerc file and the section to read from. The default is always ~/.edgerc, though the default section varies from API to API. Entering the credential attributes as individual params is currently not supported, and would be a hassle to implement.
3. All functions must support AccountSwitchKey params. This is a feature only used by Partners and Akamai internal users, but keeps the function universally usable.
4. Please use approved Powershell verbs where applicable. The use of List is fine, as are others when the approved verb would be confusion (like deleting or invalidating from cache. 'removing' isn't really a thing)
5. Please arrange functions into folders based on the name of the API as Akamai have stated it (see the existing folder structure for examples)
6. Update functions (POST/PUT) should have a $Body param for the user to specify the JSON body for the request or an -InputFile param to specify body from a file. If you also wish to allow users to specify individual params and construct the request in the function, that is fine, but make sure the JSON body and individual params are in different Parameter Sets to avoid confusion. Check New-PropertyVersion for an example

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