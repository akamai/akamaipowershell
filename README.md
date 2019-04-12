# Akamai Powershell

This module is designed to abstract the sometimes complex Akamai API commands, and its auth in particular. It can be used in Powershell 5.x or 6 (possibly earlier versions, though these are entirely untested), and there is no reason it won't work on MacOS or Linux, though these are also currently outside the scope of testing. It is in no way complete, but rather is meant to be a collaborative effort to provide Powershell implementation of most (if not all) Akamai APIs. Pull requests are welcome, and encouraged!

The central function of the module is Invoke-AkamaiOpen, which is a heavily modified version of the work you can find [here](https://github.com/akamai/AkamaiOPEN-edgegrid-powershell). There is an announcement pertaining to the EOL of Powershell support (which you should read) but ignore the warning about Akamai actively blocking PS connections, as that was supposed to happen months back and is yet to materialise. It's also probably impractical to actually do, so don't worry about it.

*Note: NO WARRANTY of any kind is offered, or should be inferred. If you use this module and break your stuff, that's your own issue. These APIs are super-powerful and this is nothing beyond some syntax checking to ensure you don't burn your own setup down.*

### Usage

1. Create and populate your .edgerc file in accordance with Akamai recommendations [here](https://developer.akamai.com/legacy/introduction/Conf_Client.html) though I would recommend skipping the Python script and just writing the .edgerc file manually.
2. Clone the repo to your local disk
3. Import the module using the standard command `Import-Module path/to/module/AkamaiPowershell.psm1`

### Contribution

If you find there are functions missing (and there are many, many missing) please contribute to the module, following these recommendations

1. All functions must be (where practical) single-use functions, not multi-function scripts. If you wish to write complex scripts, great, but keep this module to just building blocks.
2. Currently, all functions must read credentials from your ~/.edgerc file, though you may specify the section. Entering the credential attributes as individual params is currently not supported, and would be a hassle to implement. Adding support for specifying a different file is in the works.
3. All functions must support AccountSwitchKey params. This is an internal Akamai feature, but keeps the function universally usable.
4. Please use approved Powershell verbs where applicable. The use of List is fine, as are others when the approved verb would be confusion (like deleting or invalidating from cache. 'removing' isn't really a thing)
5. Please arrange functions into folders based on the name of the API as Akamai have stated it (see the existing folder structure for examples)
6. Update functions (POST/PUT) should have a $Body param for the user to specify the JSON body for the request. If you also wish to allow users to specify individual params and construct the request in the function, that is fine, but make sure the JSON body and individual params are in different Parameter Sets to avoid confusion. Check New-PropertyVersion for an example