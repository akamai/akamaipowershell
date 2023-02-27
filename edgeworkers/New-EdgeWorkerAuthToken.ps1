function New-EdgeWorkerAuthToken
{
    [CmdletBinding(DefaultParameterSetName = 'hostname')]
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='hostname')]   [string] $Hostname,
        [Parameter(Mandatory=$true,ParameterSetName='hostnames')]  [string] $Hostnames,
        [Parameter(Mandatory=$true,ParameterSetName='propertyid')] [string] $PropertyID,
        [Parameter(Mandatory=$false)] [int] $Expiry = 480,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edgeworkers/v1/secure-token"
    $BodyObj = [PSCustomObject] @{
        expiry = $Expiry
    }

    if($PSCmdlet.ParameterSetName -eq 'hostname'){
        $BodyObj | Add-Member -MemberType NoteProperty -Name 'hostname' -Value $Hostname
    }
    elseif($PSCmdlet.ParameterSetName -eq 'hostnames'){
        $BodyObj | Add-Member -MemberType NoteProperty -Name 'hostnames' -Value ($Hostnames -split ',')
    }
    elseif($PSCmdlet.ParameterSetName -eq 'propertyid'){
        $BodyObj | Add-Member -MemberType NoteProperty -Name 'propertyId' -Value $PropertyID
    }

    $Body = ConvertTo-Json $BodyObj

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.akamaiEwTrace
    }
    catch {
        throw $_
    }
}