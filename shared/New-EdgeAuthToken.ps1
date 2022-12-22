function New-EdgeAuthToken
{
    [CmdletBinding(DefaultParameterSetName = 'attributes')]
    Param(
        [Parameter(Mandatory=$true)]  [string] $Secret,
        [Parameter(Mandatory=$false)] [int]    $StartTime,
        [Parameter(Mandatory=$false)] [int]    $EndTime,
        [Parameter(Mandatory=$false)] [int] $DurationInSeconds,
        [Parameter(Mandatory=$false)] [int] $DurationInMinutes,
        [Parameter(Mandatory=$false)] [int] $DurationInHours,
        [Parameter(Mandatory=$false,ParameterSetName='acl')] [string] $ACL,
        [Parameter(Mandatory=$false,ParameterSetName='url')] [string] $URL,
        [Parameter(Mandatory=$false)] [switch] $EscapeInputs,
        [Parameter(Mandatory=$false)] [string] $IP,
        [Parameter(Mandatory=$false)] [string] $Data,
        [Parameter(Mandatory=$false)] [string] $ID,
        [Parameter(Mandatory=$false)] [string] $Salt,
        [Parameter(Mandatory=$false)] [string] $Delimiter = '~',
        [Parameter(Mandatory=$false)] [string] [ValidateSet('sha256','sha1','md5')] $Algorithm = 'sha256'
    )

    $DefaultDuration = 900 # Set 15m in the absence of actual setting
    $TokenArray = @()

    ### ip
    if($IP){
        $TokenArray += "ip=$IP"
    }

    ### st
    if($StartTime){
        $Start = $StartTime
    }
    else{
        $Start = [long] (Get-Date -Date ((Get-Date).ToUniversalTime()) -UFormat %s)
    }

    $TokenArray += "st=$Start"
    
    ### exp
    if($EndTime){
        $End = $EndTime
    }
    else {
        if($DurationInSeconds){
            $End = $Start + $DurationInSeconds
        }
        elseif($DurationInMinutes){
            $End = $Start + ($DurationInMinutes * 60)
        }
        elseif($DurationInHours){
            $End = $Start + ($DurationInHours * 3600)
        }
        else{
            Write-Warning "Neither EndTime nor Duration specified. Setting token duration to 15m"
            $End = $Start + $DefaultDuration
        }
    }

    $TokenArray += "exp=$End"

    ### acl
    if($ACL){
        $TokenArray += "acl=$ACL"
    }

    ### id
    if($ID){
        $TokenArray += "id=$ID"
    }

    ### data
    if($Data){
        $TokenArray += "data=$Data"
    }

    $HashArray = $TokenArray.PSObject.Copy()

    ### url (hash only)
    if($URL){
        if($EscapeInputs){
            $URL = [System.Web.HttpUtility]::UrlEncode($URL)
            $URL = $URL.replace('*','%2a')
        }
        $HashArray += "url=$URL"
    }

    ### salt (hash only)
    if($Salt){
        $HashArray += "salt=$Salt"
    }

    $SigningString = $HashArray -join $Delimiter
    Write-Debug "Signing string = $Signingstring"

    # Generate HMAC
    switch($Algorithm){
        "sha1"      { $HMAC = New-Object System.Security.Cryptography.HMACSHA1 }
        "sha256"    { $HMAC = New-Object System.Security.Cryptography.HMACSHA256 }
        "md5"       { $HMAC = New-Object System.Security.Cryptography.HMACMD5 }
    }

    $HMAC = New-Object System.Security.Cryptography.HMACSHA256
    $HMAC.key = [byte[]] -split ($Secret -replace '..', '0x$& ') # Secret is presented as string, but we need to treat each pair of characters as Hex before getting their byte value
    $Hash = $HMAC.ComputeHash([Text.Encoding]::UTF8.GetBytes($SigningString))
    $Signature = ($Hash | foreach ToString x2) -join ''

    $TokenArray += "hmac=$Signature"
    $Token = $TokenArray -join $Delimiter

    return $Token
}