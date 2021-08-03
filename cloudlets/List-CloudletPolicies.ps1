function List-CloudletPolicies
{
    [CmdletBinding(DefaultParameterSetName = 'all')]
    Param(
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [switch] $IncludeDeleted,
        [Parameter(Mandatory=$false)] [string] $CloudletID,
        [Parameter(Mandatory=$false)] [string] $Offset,
        [Parameter(Mandatory=$false)] [string] $Pagesize,
        [Parameter(Mandatory=$false)] [switch] $All,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($All -and $PSVersionTable.PSVersion.Major -lt 6){
        throw "the -All option is only available in Powershell 6 or newer"
    }

    # Nullify false switches
    $IncludeDeletedString = $IncludeDeleted.IsPresent.ToString().ToLower()
    if(!$IncludeDeleted){ $IncludeDeletedString = '' }

    $Path = "/cloudlets/api/v2/policies?gid=$GroupID&includedeleted=$IncludeDeletedString&cloudletId=$CloudletId&clonepolicyid=$ClonePolicyID&offset=$Offset&pageSize=$PageSize&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -ResponseHeadersVariable ResponseHeaders -EdgeRCFile $EdgeRCFile -Section $Section

        # If -all is selected, loop through paged responses until you get to the end.
        if($All){
            if($ResponseHeaders.Link){
                $NextPresent = $ResponseHeaders.Link | Select-String -pattern '^.*,.*offset=([\d]+).*pageSize=([\d]+)>;\s+rel=\"next\".*$'
                if($NextPresent){
                    $NextOffset = $NextPresent.Matches.Groups[1].Value
                    $NextPageSize = $NextPresent.Matches.Groups[2].Value

                    if($NextOffset -and $NextPageSize){
                        if($IncludeDeleted){
                            $PagedResult = List-CloudletPolicies -GroupID $GroupID -IncludeDeleted -CloudletID $CloudletID -Offset $NextOffset -Pagesize $NextPageSize -All -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
                        }
                        else{
                            $PagedResult = List-CloudletPolicies -GroupID $GroupID -CloudletID $CloudletID -Offset $NextOffset -Pagesize $NextPageSize -All -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
                        }
                        $Result += $PagedResult
                    }
                }
            }

        }

        return $Result
    }
    catch {
        throw $_.Exception
    }
}