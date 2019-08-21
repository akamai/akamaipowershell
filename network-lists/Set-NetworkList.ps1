function Set-NetworkList
{
    Param(
        [Parameter(Mandatory=$true)] [string] $NetworkListID,
        [Parameter(Mandatory=$true)] [string] [ValidateSet('add', 'remove')] $Operation,
        [Parameter(Mandatory=$true)] [string] $Element,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/network-list/v2/network-lists/$NetworkListID/elements?accountSwitchKey=$AccountSwitchKey"

    switch($Operation){
        'add' {
            $Path += "&element=$Element"
            $Method = 'PUT'
        }
        'remove' {
            $Method = 'DELETE'
        }
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method $Method -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}

