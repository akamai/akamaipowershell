function Get-EdgeWorkerAuthToken
{
    [CmdletBinding(DefaultParameterSetName = 'hostname')]
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='hostname')]   [string] $Hostname,
        [Parameter(Mandatory=$true,ParameterSetName='propertyid')] [string] $PropertyID,
        [Parameter(Mandatory=$false)] [string] $ACL = "/*",
        [Parameter(Mandatory=$false)] [string] $URL = "/*",
        [Parameter(Mandatory=$false)] [int] $Expiry = 15,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('STAGING','PRODUCTION')] $Network,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edgeworkers/v1/secure-token?accountSwitchKey=$AccountSwitchKey"
    $BodyObj = [PSCustomObject] @{
        expiry = $Expiry
    }

    if($PSCmdlet.ParameterSetName -eq 'hostname'){
        $BodyObj | Add-Member -MemberType NoteProperty -Name 'hostname' -Value $Hostname
    }
    elseif($PSCmdlet.ParameterSetName -eq 'propertyid'){
        $BodyObj | Add-Member -MemberType NoteProperty -Name 'propertyId' -Value $PropertyID
    }

    ### Both options are default
    if($ACL -eq '/*' -and $URL -ne '/*'){
        $URL = ''
        Write-Debug "ACL and URL are default. Setting URL to empty string"
    }
    ### ACL has been set
    if($ACL -ne '/*'){
        $URL = ''
        Write-Debug "ACL is not default. Setting URL to empty string"
    }
    ### URL has been set
    elseif($URL -ne '/*'){
        $ACL = ''
        Write-Debug "URL is not default. Setting ACL to empty string"
    }

    if($ACL -ne ''){
        $BodyObj | Add-Member -MemberType NoteProperty -Name 'acl' -Value $ACL
    }
    elseif($URL -ne ''){
        $BodyObj | Add-Member -MemberType NoteProperty -Name 'url' -Value $URL
    }

    if($Network -ne ''){
        $BodyObj | Add-Member -MemberType NoteProperty -Name 'network' -Value $Network
    }

    $Body = $BodyObj | ConvertTo-Json -Depth 100

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.akamaiEwTrace
    }
    catch {
        throw $_
    }
}
