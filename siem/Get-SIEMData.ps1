<#
.SYNOPSIS
EdgeGrid Powershell - SIEM API
.DESCRIPTION
Collect SIEM data
.PARAMETER ConfigID
Configuration ID of AppSec config. REQUIRED
.PARAMETER Offset
Fetches only security events that have occurred from offset
.PARAMETER Limit
Maximum number of events to fetch
.PARAMETER From
The start of a specified time range, expressed in Unix epoch seconds. OPTIONAL
.PARAMETER To
The end of a specified time range, expressed in Unix epoch seconds. OPTIONAL
.PARAMETER EdgeRCFile
Path to .edgerc file, defaults to ~/.edgerc. OPTIONAL
.PARAMETER ContractId
.edgerc Section name. Defaults to 'default'. OPTIONAL
.PARAMETER AccountSwitchKey
Account switch key if applying to an account external to yoru API user. Only usable by Akamai staff and partners. OPTIONAL
.EXAMPLE
Get-SIEMData -ConfigID 12345 -From 1634553896 -To 1634553996
.LINK
developer.akamai.com
#>

function Get-SIEMData
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ConfigID,
        [Parameter(Mandatory=$true,ParameterSetName="offset")] [string] $Offset,
        [Parameter(Mandatory=$true,ParameterSetName="fromto")] [string] $From,
        [Parameter(Mandatory=$true,ParameterSetName="fromto")] [string] $To,
        [Parameter(Mandatory=$false)] [string] $Limit,
        [Parameter(Mandatory=$false)] [switch] $Decode,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/siem/v1/configs/$ConfigID`?offset=$Offset&limit=$Limit&from=$From&to=$To&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
    }
    catch {
        throw $_.Exception 
    }

    $Events = New-Object -TypeName System.Collections.ArrayList
    $Output = New-Object -TypeName PSCustomObject

    ### Invoke-RestMethod doesn't handle the json due to it being multiple objects, so we split on line breaks, then convert to objects in an array
    if($Result.GetType().Name -eq "String"){
        ## Parse out empty last line
        if($Result.EndsWith("`n")){
            $Result = $Result.SubString(0,($Result.Length - 1))
        }
        $ResultArray = $Result -split "`n"
        $ResponseContext = $ResultArray[-1] | ConvertFrom-Json -Depth 100

        if($ResultArray.count -gt 1){
            $UnprocessedEvents = $ResultArray[0..($ResultArray.Count - 2)]
            foreach($JSONEvent in $UnprocessedEvents) {
                $Event = $JSONEvent | ConvertFrom-Json -Depth 100
                if($Decode){
                    ## Call parsing function to url and base64-decode event members
                    $ParsedEvent = Parse-SIEMEvent -Event $Event
                    $Events.Add($ParsedEvent) | Out-Null
                }
                else{
                    $Events.Add($Event) | Out-Null
                }
            }
        }
        else{
            $Events = $null
        }

        $Output | Add-Member -MemberType NoteProperty -Name "Events" -Value $Events
        $Output | Add-Member -MemberType NoteProperty -Name "ResponseContext" -Value $ResponseContext
    }
    else{
        $Output | Add-Member -MemberType NoteProperty -Name "Events" -Value $null
        $Output | Add-Member -MemberType NoteProperty -Name "ResponseContext" -Value $Result
    }
    
    return $Output
}