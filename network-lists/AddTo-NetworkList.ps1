function AddTo-NetworkList
{
    Param(
        [Parameter(Mandatory=$true)] [string] $NetworkListID,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)] [string] $Element,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/network-list/v2/network-lists/$NetworkListID/elements?element=$Element&accountSwitchKey=$AccountSwitchKey"

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_
        }
    }

    end{}
    
}
