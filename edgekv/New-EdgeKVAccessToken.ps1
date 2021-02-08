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
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )
    
    $Path = "/edgekv/v1/tokens?accountSwitchKey=$AccountSwitchKey"

    if($PSCmdlet.ParameterSetName -eq "attributes"){
        $DateTimeMatch = '[\d]{4}-[\d]{2}-[\d]{2}T[\d]{2}:[\d]{2}:[\d]{2}Z'
        if($Expiry -notmatch $DateTimeMatch){
            throw "ERROR: Expiry must be in the format 'YYYY-MM-DDThh:mm:ssZ'"
        }

        $BodyObj = @{
            name = $Name
            allow_on_production = $AllowOnProduction.IsPresent
            allow_on_staging = $AllowOnStaging.IsPresent
            expiry = $Expiry
            namespace_permissions = @{ $Namespace = @() }
        }

        $Permissions.ToCharArray() | foreach {
            if($_ -ne 'r' -and $_ -ne 'w' -and $_ -ne 'd'){
                throw "Permissions must be 'r', 'w' or 'd'"
            }
            $BodyObj.namespace_permissions.$Namespace += $_
        }

        $Body = $BodyObj | ConvertTo-Json -depth 100
    
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}