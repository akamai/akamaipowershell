# Akamai Powershell

_WARNING: This module is now deprecated and we strongly advise you to upgrade to version 2, the code for which [can be found here](https://github.com/akamai/powershell). See [our documentation](https://techdocs.akamai.com/powershell/docs/overview) for more information._

This module is designed to abstract the sometimes complex Akamai API commands, and their auth in particular. It can be used in Powershell 5.x or later (6+ is recommended), and has been tested on MacOS and Linux. It is in no way complete, but rather is meant to be a collaborative effort to provide Powershell implementation of most (if not all) Akamai APIs. Pull requests are welcome, and encouraged!

The central function of the module is Invoke-AkamaiRestMethod, which is a heavily modified version of the deprecated Invoke-AkamaiOpen you can find [here](https://github.com/akamai/AkamaiOPEN-edgegrid-powershell).

_Note: NO WARRANTY of any kind is offered, or should be inferred. These APIs are very powerful and this module will do little beyond basic syntax checking and will not prevent you doing unspeakable things to your infrastructure if you instruct it to do so._

### Getting Started

We have produced an ever-growing set of documentation which should tell you most of what you need to know. You can find it here - https://techdocs.akamai.com/powershell/docs/overview

### Proxy Support

If you wish to use an https proxy with your commands, simply set the _$env:https_proxy_ environment variable to your proxy address (e.g. http://localhost:8888). Once complete set the variable back to $null. Remember that this variable will presist for the remainder of your session, so could cause odd behaviors if left in place and the proxy disabled.

### Contribution

If you find there are functions missing please contribute to the module, following these recommendations

1. All functions must be (where practical) single-use functions, not multi-function scripts. If you wish to write complex scripts, great, but keep this module to just building blocks.
2. All functions must contain parameters for EdgeRCFile and Section
3. All functions must support AccountSwitchKey params. This is a feature only used by Partners and Akamai internal users, but keeps the function universally usable.
4. Please use approved Powershell verbs where applicable. We are moving to a 100% approved-verb model in version 2
5. Please arrange functions into folders based on the name of the API as Akamai have stated it (see the existing folder structure for examples)
6. Update functions (POST/PUT) should have a $Body param for the user to specify the JSON body for the request, or an -InputFile param to specify body from a file if appropriate. If you also wish to allow users to specify individual params and construct the request in the function, that is fine, but make sure the JSON body and individual params are in different Parameter Sets to avoid confusion. Check New-PropertyVersion for an example
7. Similarly to 6. include a pipeline option for any New- or Set- functions. This requires begin/process/end code blocks and param options

### Licensing

Copyright 2023 Akamai Technologies

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
