function New-EdgeHostname
{
    Param(
        [Parameter(ParameterSetName='attributes', Mandatory=$true)] [string] $DomainPrefix,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)] [string] [ValidateSet('akamaized.net', 'edgesuite.net', 'edgekey.net')] $DomainSuffix,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)] [string] [ValidateSet('IPV4', 'IPV6_COMPLIANCE', 'IPV6_PERFORMANCE')] $IPVersionBehavior,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)] [string] $ProductID,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] [ValidateSet('ENHANCED_TLS', 'STANDARD_TLS', 'SHARED_CERT')] $SecureNetwork,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [int] $SlotNumber,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [int] $CertEnrollmentID,
        [Parameter(ParameterSetName='postbody', Mandatory=$true)]   [string] $Body,
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $Options,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/edgehostnames?contractId=$ContractId&groupId=$GroupID&options=$Options"

    if($PSCmdlet.ParameterSetName -eq 'attributes')
    {
        $BodyObj = @{
            'productId' = $ProductID
            'domainPrefix' = $DomainPrefix    
            'domainSuffix' = $DomainSuffix
            'ipVersionBehavior' = $IPVersionBehavior
        }

        if($SecureNetwork -ne ''){ $BodyObj['secureNetwork'] = $SecureNetwork }
        if($SlotNumber){ $BodyObj['slotNumber'] = $SlotNumber }
        if($CertEnrollmentID){ $BodyObj['certEnrollmentId'] = $CertEnrollmentID }

        $Body = $BodyObj | ConvertTo-Json -depth 100
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey -Body $Body
        return $Result
    }
    catch {
        throw $_
    }
}
