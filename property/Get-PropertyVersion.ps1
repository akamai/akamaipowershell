function Get-PropertyVersion
{
    Param(
      [Parameter(Mandatory=$true)]  [string] $PropertyId,
      [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
      [Parameter(Mandatory=$false)] [string] $GroupID,
      [Parameter(Mandatory=$false)] [string] $ContractId,
      [Parameter(Mandatory=$false)] [switch] $XML,
      [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
      [Parameter(Mandatory=$false)] [string] $Section = 'papi',
      [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/properties/$PropertyId/versions/$PropertyVersion`?contractId=$ContractId&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"
    
    try {
        if($XML)
        {
            $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -XML
        }
        else
        {
            $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        }
        return $Result.versions.items
    }
    catch {
        throw $_.Exception
    }
}

