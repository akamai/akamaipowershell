function Get-AccountHostnames {
    Param(
        [Parameter(Mandatory = $false)] [string] $Offset,
        [Parameter(Mandatory = $false)] [string] $Limit,
        [Parameter(Mandatory = $false)] [string] [ValidateSet('hostname:a', 'hostname:d')] $Sort,
        [Parameter(Mandatory = $false)] [string] $Hostname,
        [Parameter(Mandatory = $false)] [string] $CnameTo,
        [Parameter(Mandatory = $false)] [string] [ValidateSet('PRODUCTION', 'STAGING')] $Network,
        [Parameter(Mandatory = $false)] [string] $ContractID,
        [Parameter(Mandatory = $false)] [string] $GroupID,
        [Parameter(Mandatory = $false)] [string] $EdgeRCFile,
        [Parameter(Mandatory = $false)] [string] $Section,
        [Parameter(Mandatory = $false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/hostnames?offset=$Offset&limit=$Limit&sort=$Sort&hostname=$Hostname&cnameTo=$CnameTo&network=$Network&contractId=$ContractId&groupId=$GroupID"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        $TotalHostnames = $Result.hostnames.items
        if ($Result.hostnames.nextLink -match '.*offset=([\d]+)&limit=([\d]+).*') {
            $NextOffset = $Matches[1]
            $NextLimit = $Matches[2]
            Write-Debug "Retrieving next page of response with offset = $NextOffset and limit = $NextLimit. Please wait..."
            $NextParams = @{
                OffSet           = $NextOffset
                Limit            = $NextLimit
                Hostname         = $Hostname
                CnameTo          = $CnameTo
                ContractID       = $ContractID
                GroupID          = $GroupID
                EdgeRCFile       = $EdgeRCFile
                Section          = $Section
                AccountSwitchKey = $AccountSwitchKey
            }
            if ($Sort) { $NextParams.Sort = $Sort }
            if ($Network) { $NextParams.Network = $Network }
            $TotalHostnames += Get-AccountHostnames @NextParams
        }
        return $TotalHostnames
    }
    catch {
        throw $_
    }
}