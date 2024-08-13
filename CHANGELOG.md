# AkamaiPowershell PowerShell Module

# Changelog

## 1 13.0 (13/8/2024)

### Deprecations and v2 warnings

Version 2 of the Akamai module has been released, so we are now actively pushing users to upgrade. This is the last release of v1, so please consult our documentation about an upgrade path. Note: You must remove v1 before installing v2, as there is no direct update available.

- [All] Removed deprecated TCM API
- [BotMan / Billing / LDS] Code removed due to API being classified as sensitive. A new version will be released behind a Control Centre login
- [CPS] Fixed issue in Get-CPSDVHistory response
- [AppSec] Fixed HTTP method on Remove-AppSecConfigurationVersion
- [Cloudlets] Expanded acceptable Cloudlet types for New-SharedCloudletPolicy
- [Examples] Fixed List-HostnamesInContract script for PowerShell 5.1 users
- [ChinaCDN] Fixed missing parameter on several functions
- [Datastream] Removed functions which called deprecated v1 of the DS API
- [Image Manager] Removed deprecated ImageCollection functions
- [Shared] Added option to handle location header in 200 response in pwsh 7.4+
- [Shared] Removed scoping on code to disable 100-continue 

## 1.12.0 (3/11/2023)

### Signing updates, proxy credential support & bugfixes

- [Shared] - Requests now use utf8 encoding for generating the signature, which means non-ascii characters will not break signing
- [Shared] - Incorporated proxy credential support change from https://github.com/akamai/akamaipowershell/pull/47. Thanks to rootadin! (and sorry for the delay...)
- [Property] - New functions to list all hostnames in an account (Get-AccountHostnames) and hostname audit history (Get-HostnameAuditHistory)
- [Property] - Better handling of 'latest' version for Get-PropertyRuleTemplates
- [Reporing] - Bugfixes for use of -Metrics and -Filters options where options were encoded incorrectly

> Note: This really is the last release of version 1. We really mean it this time...

## 1.11.0 - (2/5/2023)

### Hostname Bucket support, cleanup & many fixes

- [Property] - Added functions to cover the new Hostname Buckets feature
- [Cleanup] - Functions for the following deprecated APIs have been removed: Diagnostic Tools, DataStream 1, SPS
- [Image & Video Manager] - Added PolicySet functions, and moved various existing endpoints from v0 to v2
- [AppSec] - Updated Activate-AppSecConfiguration to use new endpoint, broken due to the previous path being deprecated
- [AppSec] - Added new function List-AppSecAvailableHostnames
- [Property] - Fixed Type in PeerReviewedBy parameter
- [Reporting] - Updated $ReportType variable to $Name, in-line with API definition. -ReportType can still be used due to a backward-compatible alias
- [SiteShield] - Updated $SiteShieldID variable to $ID, in-line with API definition. -SiteshieldID can still be used due to a backward-compatible alias
- [Cloudlets] - Fixed a bug in New-CloudletPolicy which did not clone existing policy rules
- [Cloudlets] - Fixed a typo which prevented List-CloudletLoadBalancers from appearing
- [Purge] - Deprecated functions removed and section default has been changed from 'ccu' to 'default', in-line with other commands
- [MediaDeliveryReports] - Fixed a bug which prevented Get-AMDDeliveryData from functioning corrected
- [EdgeDiagnostics] - Changed Get-DiagnosticLink to New-DiagnosticLink, in-line with its method
- [Netstorage] - Fixed a bug which did not read credentials correctly from auth file sections other than 'default'
- [MSL] - Fixed missing Path variable in New-MSLOrigin and Set-MSLOrigin
- [GTM] - Fixed path bug in Get-GTMDatacenterLatency

> Note: This is likely to be the last release of version 1 of the AkamaiPowershell module. We are working on a completely overhauled version 2, so all new features will be available there. Any major bugs will still be back-ported to v1

## 1.10.0 - (23/02/2023)

### Adding support for alternate auth options and structural improvements

-  [Shared] - We now support credentials from Environment Variables for {OPEN} APIs. Set AKAMAI_HOST, AKAMAI_CLIENT_TOKEN, AKAMAI_CLIENT_SECRET and AKAMAI_ACCESS_TOKEN variables to use, or AKAMAI_<SECTION NAME>_HOST etc. and use the -Section parameter with <SECTION NAME> (section name is not case sensitive but variable names are)
-  [Netstorage] - Also support credentials from Environment variables, as with {OPEN} APIs above. Use NETSTORAGE_KEY, NETSTORAGE_ID, NETSTORAGE_GROUP, NETSTORAGE_HOST, & NETSTORAGE_CPCODE, or use NETSTORAGE_<SECTION NAME>_KEY etc. and use the -Section parameter with <SECTION NAME> (section name is not case sensitive but variable names are)
-  [Shared] - Module FunctionsToExport is now populated with an explicit list, rather than a wildcard. This will fix the auto-import issues previously and should mean you no longer need to use Import-Module
-  [Edgeworkers] - BREAKING: Updated New-EdgeWorkerAuthToken to a POST method rather than the deprecated offline Token Auth method
-  [EdgeWorkers] - Fix for bundle tar creation. This should now work on Windows, MacOS and Linux in the same way
-  [EdgeWorkers] - Various new endpoints, including the ability to download a code bundle in tgz format
-  [Billing] - Old billing API deprecated and replaced with 3 new functions
-  [EdgeKV] - New endpoints for managing groups
-  [Shared] - Fix for any functions (e.g. New-EdgeWorkerVersion) where the method is POST and which use an InputFile param where the file is larger than 128KB
-  [Shared] - Fixes for update check

## 1.9.2 - (25/01/2023)

### Removing .git contents from package

Folder was un-hidden and mistakenly included in published module, greatly increasing its size.

## 1.9.0 - (06/01/2023)

### Bot Manager, Edge Diagnostics & Assorted fixes

-   [Bot Manager] - Added Bot Manager API functions
-   [Edge Diagnostics] - Added Edge Diagnostics API functions to replace deprecated Diagnostic Tools endpoints
-   [Reporting] -Tweaked ISO8601 match in reporting functions to allow timezones other than UTC
-   [Shared] - Added function to generate Token Auth key, New-EdgeAuthToken
-   [Shared] - Simplified EdgeRC and Netstorage Auth file parsing
-   [Shared] - EdgeRC parsing now supports account_key param, meaning you can include this in your .edgerc file rather than including -AccountSwitchKey with every command
-   [General] - Added update checker
-   [General] - Enforced lf for all line endings to help with cross-platform development
-   [PAPI] - Made -AcknowledgeAllWarnings default in Activate-Property, so it is no longer required (but still supported)
-   [PAPI] - Added -IncludeCertStatus switch to List-PropertyHostnames and Set-PropertyHostnames, which includes SbD statuses in output
-   [PAPI] - Incorporated K-a-r-l's fix for List-AllProperties
-   [Fixes] - Corrected various instances where file and function name differed, which prevents use of function
-   [Fixes] - Various bug fixes for Cloudlets, CP Codes, HAPI, API Key Manager and others

## 1.8.0 - (05/09/2022)

### AppSec, DataStream, Cloudlets & more

-   Updated support for AppSec API 2021 and 2022 features
-   (BREAKING) Datastream functions now default to Datastream 2. DS1 functions now with specific function names
-   New Shared cloudlet functions for Cloudlets API v3
-   Support for PM Includes feature, currently in beta
-   (Potentially BREAKING) Errors thrown are now complete, without the ErrorDetails child object. This was only partially implemented previously, which caused thrown errors to be masked and generally of no use.
-   Support for API Key Manager API, which handles API Key Collections and Throttling for API Gateway
-   Support for Cloud Access Manager API
-   Bugfixes for Netstorage and various other functions

## 1.7.0 - (24/03/2022)

### Signing, testing and general improvements

-   Code is now digitally signed, allowing use on clients with ExecutionPolicy of RemoteSigned or AllSigned
-   Pester testing added for Property, CPS, NSAPI, EdgeWorkers, EdgeKV & NetworkLists
-   CPS request formats are now updated to the latest versions
-   New options for creation and editing of Network Lists
-   Overhaul of Nestorage auth file parsing to support spacing, along with fixes to NS commands
-   New endpoints to bring EdgeKV API support up to date, particularly in access tokens
-   New endpoints to bring EdgeWorker API support up to date, including auth token endpoint support
-   Added spacing support for .edgerc files
-   Added Deactivate-Property function
-   Updating PS 6+ thrown errors to throw entire error, rather than ErrorDetails sub-member. Change already made for PS 5
-   Fixing incompatibility with PS 5 for Set-PropertyRuleTree, Set-PropertyHostnames, Merge-PropertyRuleTemplates and Invoke-AkamaiRestMethod

## 1.6.2 - (14/12/2021)

### Edgeworker improvements

Fixes for parametersetname bug which prevented new versions being created, as well as cmdletbinding, new Remove- functions and pester testing overhaul.

## 1.6.1 - (13/12/2021)

### Templating bugfixes

Fixes for a few minor issues in the new property template logic.

## 1.6.0 - (06/12/2021)

### Templates, AppSec, Cloudlets and more

Lots of new updates included in this release:

New PAPI template functions with optional depth to split your PAPI rules into multiple files
Splitting out EdgeRC parsing into a separate function so it can be reused in IDM
Policy name support for AppSec API
Improvements to cloudlets functions
Custom UserAgent so we can track who is using the module and which versions they are on
Fix for Get-CustomBehavior output

---

## 1.5.1 - (28/09/2021)

### Empty POST support, new cloudlet features

This release contains various bugfixes and minor new features. Primarily, it deals with POSTs with no body, which generated invalid signatures, as well as adding "latest" support in the cloudlets API.

---

## 1.5.0 - (20/08/2021)

### Simplified sections, new support options

NOTE: This release contains potentially breaking changes, specifically to the default values of the $Section parameter. Please read the following thoroughly before updating.

Changed default section to 'default' for all but CCU APIs
Added lots of new AppSec functions
Now support comments in .edgrc lines
New Cloudlet download function
Now support rolloutDuration in Image Manager
New Image Manager rollback function
Fixes for Netstorage on Powershell 5

---

## 1.4.1 - (15/06/2021)

### Bugfix for Powershell 5.x clients, minor functional updates

Major bug was causing multiple POSTs in the shared Invoke-AkamaiRestMethod function call for PS 5.x, which would then error out.

---

## 1.4.0 - (03/03/2021)

### TC, ChinaCDN, EdgeWorkers, EdgeKV, DS2, IVM

New APIs included:

Test Center
ChinaCDN
EdgeWorkers & EdgeKV
Datastream 2

Apis Updated:
Image & Video Manager - Total overhaul of new functions to support new endpoints. Includes support for account switching

---

## 1.3.1 - (15/12/2020)

### AppSec, Datastream and more

Various bugfixes and better sanitisation for query strings

---

## 1.3.0 - (25/11/2020)

### AppSec, Datastream and more

Added complete support for new AppSec endpoints, DS config API, Billing API, expanded LDS coverage and tons of other fixes

---

## 1.1.1 - (14/09/2020)

### Bug fixes for PAPI endpoints

Fixed issues with PAPI activation endpoint and corrected an issue with piping hostnames into Set-PropertyHostnames

---

## 1.1 - (07/09/2020)

### .edgerc validation

Various bugfixes, primarily now the ability to add -Debug to cmdlets which will be passed through to Invoke-AkamaiRestMethod which will output info on invalid .edgerc data

---

## 1.0.3 - (17/07/2020)

### Adding Datastream 'now' option

Minor new feature to convert "now" to current time minus 1 minute for Datastream, since it complains if the time is in the future.

---

## 1.0.2 - (01/07/2020)

### Bugfixes and new pipeline options

Corrects a major flaw in Set-PropertyRuleTree where the old $Rules variable was referenced incorrectly, and added more pipeline input options to cmdlets.

---

## 1.0.1 - (17/06/2020)

### Adding pipeline support

Adding pipeline support to Set-PropertyRuleTree as a canary for other cmdlets, and rearchitected .edgerc support

---

## 1.0.0 - (01/05/2020)

### Initial Gallery Release

Publishing to Powershell Gallery
