<#
.SYNOPSIS
SIEM Event Parsing
.DESCRIPTION
Parses encoded data in SIEM events and decodes
.PARAMETER Event
Powershell object of SIEM data
.EXAMPLE
Parse-SIEMEvent -Event $Event
.LINK
developer.akamai.com
#>

function Parse-SIEMEvent
{
    Param(
        [Parameter(Mandatory=$true)] [object] $Event
    )

    $AttackDataAttributes = @(
        'rules',
        'ruleVersions',
        'ruleMessages',
        'ruleTags',
        'ruleData',
        'ruleSelectors',
        'ruleActions'
    )

    $httpMessageAttributes = @(
        'query',
        'requestHeaders',
        'responseHeaders'
    )

    $AttackDataAttributes | foreach {
        Write-Debug "Parsing $_"
        ### Encoded data sometimes contains pluses (+) which should not be decoded
        $PlusSafeString = $Event.attackData.$_.Replace("+","%2b")
        $URLdecodedString = Decode-URL -EncodedString $PlusSafeString
        $Entries = $URLdecodedString -split ";"
        foreach($Entry in $Entries){
            if($Entry -ne ''){
                $DecodedEntry = Decode-Base64String -EncodedString $Entry
                $URLdecodedString = $URLdecodedString.Replace($Entry,$DecodedEntry)
            }
        }
        $Event.attackData.$_ = $URLdecodedString
    }

    $httpMessageAttributes | foreach{
        if($Event.httpMessage.$_){
            Write-Debug "Parsing $_"
            $URLdecodedString = Decode-URL -EncodedString $Event.httpMessage.$_
            $Event.httpMessage.$_ = $URLdecodedString -split "`n" | Where {$_ -ne ''}
        }
    }

    return $Event
}
