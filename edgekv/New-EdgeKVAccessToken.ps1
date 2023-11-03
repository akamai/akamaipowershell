function New-EdgeKVAccessToken
{
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='attributes')]  [string] $Name,
        [Parameter(Mandatory=$false,ParameterSetName='attributes')] [switch] $AllowOnProduction,
        [Parameter(Mandatory=$false,ParameterSetName='attributes')] [switch] $AllowOnStaging,
        [Parameter(Mandatory=$true,ParameterSetName='attributes')]  [string] $Expiry,
        [Parameter(Mandatory=$true,ParameterSetName='attributes')]  [string] $Namespace,
        [Parameter(Mandatory=$true,ParameterSetName='attributes')]  [string] $Permissions,
        [Parameter(Mandatory=$true,ParameterSetName='body')]        [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )
    
    $Path = "/edgekv/v1/tokens"

    if($PSCmdlet.ParameterSetName -eq "attributes"){
        ### Check expiry datetime
        try{
            $DT = Get-Date $Expiry -ErrorAction Stop
        }
        catch{
            throw "$Expiry is not a valid datetime"
        }

        $BodyObj = @{
            name = $Name
            allowOnProduction = $AllowOnProduction.IsPresent
            allowOnStaging = $AllowOnStaging.IsPresent
            expiry = $Expiry
            namespacePermissions = @{ $Namespace = @() }
        }

        $Permissions.ToCharArray() | foreach {
            if($_ -ne 'r' -and $_ -ne 'w' -and $_ -ne 'd'){
                throw "Permissions must be 'r', 'w' or 'd'"
            }
            $BodyObj.namespacePermissions.$Namespace += $_
        }

        $Body = $BodyObj | ConvertTo-Json -depth 100
    
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
