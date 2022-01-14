function New-EdgeWorkerAuthToken
{
    [CmdletBinding(DefaultParameterSetName = 'url')]
    Param(
        [Parameter(Mandatory=$true)]  [string] $Secret,
        [Parameter(Mandatory=$true,ParameterSetName='acl')] [string] $ACLPath,
        [Parameter(Mandatory=$true,ParameterSetName='url')] [string] $URLPath,
        [Parameter(Mandatory=$false)] [int] $Expiry = 15
    )

    $Delimiter = '~'
    $Token = ''
    $Start = [long] (Get-Date -Date ((Get-Date).ToUniversalTime()) -UFormat %s)
    $End = $Start + ($Expiry * 60)

    $Token += "st=$Start"
    $Token += $Delimiter
    $Token += "exp=$End"

    $HMACToken = $Token
    $HMACToken += $Delimiter
    if($ACLPath){
        $Token += $Delimiter
        $Token += "acl=$ACLPath"
        $HMACToken = $Token
    }
    else{
        $HMACToken = $Token
        $HMACToken += $Delimiter
        $EncodedURL = [System.Web.HttpUtility]::UrlEncode($URLPath)
        $HMACToken += "url=$EncodedURL"
    }

    # Generate HMAC
    $HMACSHA = New-Object System.Security.Cryptography.HMACSHA256
    $HMACSHA.key = [byte[]] -split ($Secret -replace '..', '0x$& ') # Secret is presented as string, but we need to treat each pair of characters as Hex before getting their byte value
    $Hash = $HMACSHA.ComputeHash([Text.Encoding]::UTF8.GetBytes($HMACToken))
    $Signature = ($Hash | foreach ToString x2) -join ''

    $Token += $Delimiter
    $Token += "hmac=$Signature"

    return $Token
}