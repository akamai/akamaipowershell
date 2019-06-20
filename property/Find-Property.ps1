function Find-Property
{
    Param(
        [Parameter(ParameterSetName='Name', Mandatory=$false)] [string] $PropertyName,
        [Parameter(ParameterSetName='Host', Mandatory=$false)] [string] $PropertyHostname,
        [Parameter(ParameterSetName='Edge', Mandatory=$false)] [string] $EdgeHostname,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/search/find-by-value?accountSwitchKey=$AccountSwitchKey"

    $BodyObj = @{}
    if($PropertyName) {
        $BodyObj["propertyName"] = $PropertyName
    }
    elseif($PropertyHostname) {
        $BodyObj["hostname"] = $PropertyHostName
    }
    elseif($EdgeHostname) {
        $BodyObj["edgeHostname"] = $EdgeHostname
    }

    $Body = $BodyObj | ConvertTo-Json -Depth 10 

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $Body
        $Result = $Result.versions.items | Sort-Object -Property propertyVersion -Descending
        if($null -ne $Result -and $Result.GetType().Name -eq "Object[]") {
            return $Result[0]
        }
        else {
            return $Result
        }
    }
    catch {
        throw $_.Exception
    }
}

