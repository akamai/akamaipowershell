function Get-SPSRequest
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $SPSId,
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $After,
        [Parameter(Mandatory=$false)] [switch] $Information,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $InformationString = $Information.IsPresent.ToString().ToLower()
    if(!$Information){ $InformationString = '' }

    $DateTimeMatch = '[\d]{4}-[\d]{2}-[\d]{2}T[\d]{2}:[\d]{2}:[\d]{2}Z'
    if($After -and $After -notmatch $DateTimeMatch){
        throw "ERROR: After must be in the format 'YYYY-MM-DDThh:mm:ssZ'"
    }

    $Path = "/config-secure-provisioning-service/v1/sps-request/$SPSId`?groupId=$GroupID&contractId=$ContractID&after=$After&information=$InformationString&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}

