function Invoke-AkamaiNSAPIRequest {
    Param(
        [Parameter(Mandatory=$true)] [string] $StorageGroupID,
        [Parameter(Mandatory=$true)] [string] $Path,
        [Parameter(Mandatory=$true)] [string] [ValidateSet('delete', 'dir', 'download', 'du', 'list', 'mkdir', 'ntime', 'quick-delete', 'rename', 'rmdir', 'stat', 'symlink', 'upload')] $Action,
        [Parameter(Mandatory=$true)] [string] $KeyName,
        [Parameter(Mandatory=$true)] [string] $Key,
        [Parameter(Mandatory=$false)] [string] $Body
    )

    # Check for Proxy Env variable and use if present
    if($null -ne $ENV:https_proxy)
    {
        $UseProxy = $true
    }

    #Prepend path for later use
    if(!($Path.StartsWith("/"))) {
        $Path = "/$Path"
    }

    $NSHost = "https://$StorageGroupID-nsu.akamaihd.net"

    $Headers = @{}

    $EncodedPath = [System.Web.HttpUtility]::UrlEncode($Path)

    # Action Header
    $ActionHeader = "version=1&action=$Action&format=xml"
    $Headers['X-Akamai-ACS-Action'] = $ActionHeader

    #GUID for request signing
    $Nonce = Get-RandomString -Length 20 -Hex

    # Generate X-Akamai-ACS-Auth-Data variable
    $Version = 5
    $EpochTime = [Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
    $AuthDataHeader = "$Version, 0.0.0.0, 0.0.0.0, $EpochTime, $Nonce, $KeyName"
    $Headers['X-Akamai-ACS-Auth-Data'] = $AuthDataHeader

    # Create sign-string for encrypting, reuse shared Crypto
    $SignString = "$Path\nx-akamai-acs-action:$ActionHeader\n"
    Write-Host "Sign-String: $SignString"
    $EncryptMessage = $AuthDataHeader + $SignString
    Write-Host "EncryptMessage: $EncryptMessage"
    $Signature = Crypto -secret $Key -message $EncryptMessage
    $Headers['X-Akamai-ACS-Auth-Sign'] = $Signature

    # Determine HTTP Method from Action
    Switch($Action) {
        'delete'       { $Method = "PUT"}
        'dir'          { $Method = "GET"}
        'download'     { $Method = "GET"}
        'du'           { $Method = "GET"}
        'list'         { $Method = "GET"}
        'mkdir'        { $Method = "PUT"}
        'mtime'        { $Method = "POST"}
        'quick-delete' { $Method = "POST"}
        'rename'       { $Method = "POST"}
        'rmdir'        { $Method = "POST"}
        'stat'         { $Method = "GET"}
        'symlink'      { $Method = "POST"}
        'upload'       { $Method = "PUT"}
    }

    # Set ReqURL from NSAPI hostname and supplied path
    $ReqURL = $NSHost + $Path

    $Headers

    # Do it.
    if ($Method -eq "PUT" -or $Method -eq "POST") {
        try {
            if ($Body) {
                if($UseProxy){
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -Body $Body -Proxy $ENV:https_proxy
                }
                else {
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -Body $Body
                }
                
            }
            else {
                if($UseProxy) {
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -Proxy $ENV:https_proxy
                }
                else {
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json'
                }
            }
        }
        catch {
            throw $_
        }
    }
    else {
        try {
            if($UseProxy) {
                $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -MaximumRedirection 0 -ErrorAction Stop -Proxy $ENV:https_proxy
            }
            else {
                $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -MaximumRedirection 0 -ErrorAction Stop
            }
        }
        catch {
            #Redirects aren't well handled due to signatures needing regenerated
            if($_.Exception.Response.StatusCode.value__ -eq 301 -or $_.Exception.Response.StatusCode.value__ -eq 302)
            {
                try {
                    $NewReqURL = "https://" + $_.Exception.Response.Headers.Location.Host + $_.Exception.Response.Headers.Location.PathAndQuery
                    Invoke-RestMethod -Method $Method -Uri $NewReqURL -Headers $Headers -ContentType 'application/json' -MaximumRedirection 0 -ErrorAction Stop
                }
                catch {
                    throw $_
                }
            }
            else {
                throw $_
            }
        }
    }
    
}