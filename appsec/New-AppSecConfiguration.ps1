function New-AppSecConfiguration
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Name,
        [Parameter(Mandatory=$true)]  [string] $Description,
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$true)]  [string] $Hostnames,
        [Parameter(Mandatory=$false)] [int] $CloneConfigID,
        [Parameter(Mandatory=$false)] [int] $CloneConfigVersion,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/appsec/v1/configs?accountSwitchKey=$AccountSwitchKey"
    $BodyObj = @{
        name = $Name
        description = $Description
        contractId = $ContractID
        groupId = $GroupID
        hostnames = $Hostnames -split ','
    }

    if($CloneConfigID -and $CloneConfigVersion){
        $BodyObj['createFrom'] = @{
            configId = $CloneConfigID
            version = $CloneConfigVersion
        }
    }

    $Body = $BodyObj | ConvertTo-Json

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception 
    }
}