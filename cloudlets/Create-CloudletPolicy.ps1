function Create-CloudletPolicy
{
    Param(
        [Parameter(ParameterSetName='attributes', Mandatory=$true) ] [string] $Name,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] $Description,
        [Parameter(ParameterSetName='attributes', Mandatory=$true) ] [int]    $GroupID,
        [Parameter(Mandatory=$false)] [switch] $IncludeDeleted,
        [Parameter(ParameterSetName='attributes', Mandatory=$true) ] [int]    $CloudletID,
        [Parameter(Mandatory=$false)] [int]    $ClonePolicyID,
        [Parameter(Mandatory=$false)] [string] $Version,
        [Parameter(ParameterSetName='postbody', Mandatory=$false)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $Section = 'cloudlets',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cloudlets/api/v2/policies?clonepolicyid=$ClonePolicyID&version=$Version&accountSwitchKey=$AccountSwitchKey"

    if($PSCmdlet.ParameterSetName -eq 'attributes')
    {
        $Post = @{ name = $Name; cloudletId = $CloudletID; groupId = $GroupID; description = $Description }
        $Body = ConvertTo-Json $Post -Depth 10
    }

    try {
        $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $Body
        return $Result
    }
    catch {
        return $_
    }
}

