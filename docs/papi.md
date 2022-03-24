# Property API

The Akamai Property API (PAPI) is probably the most used API we offer, simply because Property Manager is likely the most used application in the stack. With this API you can create, edit, delete, activate and deactive properties, as well as working with CP Codes and Edge Hostnames. As with most APIs included in this module, the cmdlets closely mirror the API endpoints themselves, however a few shortcut parameters have been included. For PAPI, the following are of note:

* _-PropertyName myproperty.com_ - PAPI bases its operations on a Property ID, which requires an additional step to find. Cmdlets here allow you to specify a property by name, and will find its ID for you
* _-PropertyVersion 'latest'_ - Most commands allow for using the word 'latest' in place of a numeric property version. This allows you to skip finding out what number the latest version is, which is required in some cases.

Here are a few examples you might use the included cmdlets for

## Updating the rules on an existing property

This is an extremely common practice for PM users, and while most of these operations can be done by hand, doing this multiple times or with complex rule trees would be extremely time-consuming and error prone.

1. We start with getting your property. You can do this by ID, but -PropertyName is included in the module for ease of use

```Powershell
Get-Property -PropertyName myproperty.com
```

2. You can see from the response the ID, version status etc. Assuming the current version is either Active or has been Deactivated it is not editable, so we need to create a new one.

```Powershell
New-PropertyVersion -PropertyName myproperty.com -CreateFromVersion latest
```

3. Now that we have a new version we can pull the current rule tree down as a Json file. The _-OutputToFile_ param will automatically name the file _<PropertyName>\_<PropertyVersion>.json_ . You can also use the _-OutputFileName_ param if you wish to name the file something different

```Powershell
Get-PropertyRuleTree -PropertyName myproperty.com -PropertyVersion latest -OutputToFile
```

4. Now that you have your Json you can edit the file in whichever way you wish. Remember the RuleTree does not contain any hostname info, so this method is often used to copy the rules from one property to another, either specifically or in their entirety. Once your edits are complete, you can push the changes back. For this you can either pass the rule tree as a string variable (using _-Body_), or reference the file from disk (using _-InputFile_)

```Powershell
$Update = Set-PropertyRuleTree -PropertyName myproperty.com -PropertyVersion latest -InputFile myproperty.com_2.json
```

5. Look for anything in the $Update response object's _errors_ member, as any errors will prevent you from activating. Assuming there are none, or you have corrected them, you can now activate the property. Note, the Property API forces you to acknowledge all warnings in your property inividually. This is a pain so we have added an -AutoAcknowledgeWarnings switch to do this for you.

```Powershell
Activate-Property -PropertyName mypropert.com -PropertyVersion latest -Network Staging -Note "Activated via PAPI" -NotifyEmails "bob@email.com" -AutoAcknowledgeWarnings
```