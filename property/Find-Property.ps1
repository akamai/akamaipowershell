function Find-Property
{
    Param(
        [Parameter(ParameterSetName='Name', Mandatory=$false)] [string] $PropertyName,
        [Parameter(ParameterSetName='Host', Mandatory=$false)] [string] $PropertyHostname,
        [Parameter(ParameterSetName='Edge', Mandatory=$false)] [string] $EdgeHostname,
        [Parameter(Mandatory=$false)] [switch] $Latest,
        [Parameter(Mandatory=$false)] [switch] $JustProductionActive,
        [Parameter(Mandatory=$false)] [switch] $JustStagingActive,
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
        if($Latest){
            $SortedResult = $Result.versions.items | Sort-Object -Property propertyVersion -Descending
            if($null -ne $SortedResult -and $SortedResult.GetType().Name -eq "Object[]") {
                return $SortedResult[0]
            }
            else {
                return $SortedResult
            }
        }
        elseif($JustProductionActive){
            return $Result.versions.items | Where {$_.productionStatus -eq "ACTIVE"}
        }
        elseif($JustStagingActive){
            return $Result.versions.items | Where {$_.stagingStatus -eq "ACTIVE"}
        }
        else{
            return $Result.versions.items
        }
    }
    catch {
        throw $_.Exception
    }
}

