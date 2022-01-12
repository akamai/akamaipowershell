function Set-NetworkList
{
    [CmdletBinding(DefaultParameterSetName = 'body')]
    Param(
        [Parameter(Mandatory=$true)] [string] $NetworkListID,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('set','add', 'remove')] $Operation = 'set',
        [Parameter(Mandatory=$false,ParameterSetName='pipeline',ValueFromPipeline=$true)] [object] $NetworkList,
        [Parameter(Mandatory=$false,ParameterSetName='body')]     [string] $Body,
        [Parameter(Mandatory=$false)] [string] $Element,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/network-list/v2/network-lists/$NetworkListID/elements?element=$Element&accountSwitchKey=$AccountSwitchKey"
        $Method = 'PUT'

        if($Operation -ne 'set'){
            # Validate Input
            if($Element -eq ''){
                throw '$Element param is required when adding or removing from a list'
            }
            Write-Warning 'The $Operation and $Element params will be deprecated in a future relase. Use AddTo-NetworkList or RemoveFrom-NetworkList to add or remove items.'
            if($Operation -eq 'remove'){
                $Method = 'DELETE'
            }
        }
        else{
            # Remove /elements from path until opeation is deprecated
            $Path = $Path.Replace("/elements","")
        }

        if($NetworkList){
            $Body = $NetworkList | ConvertTo-Json -Depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method $Method -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_.Exception
        }
    }

    end{}
    
}

