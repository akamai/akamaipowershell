function Get-EdgeWorkerReport
{
    [CmdletBinding(DefaultParameterSetName = 'name')]
    Param(
        [Parameter(Mandatory=$true)]  [int]    $ReportID,
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $Name,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $EdgeWorkerID,
        [Parameter(Mandatory=$true)]  [string] $Start,
        [Parameter(Mandatory=$true)]  [string] $End,
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('onClientRequest','onOriginRequest','onOriginResponse','onClientResponse','responseProvider')] $EventHandler,
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('success','genericError','unknownEdgeWorkerId','unimplementedEventHandler','runtimeError','executionError','timeoutError','resourceLimitHit')] $Status,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($Name){
        try{
            $EdgeWorker = (List-EdgeWorkers -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey) | Where {$_.name -eq $Name}
            if($EdgeWorker.count -gt 1){
                throw "Found multiple EdgeWorkers with name $Name. Use -EdgeWorkerID to be more specific"
            }
            $EdgeWorkerID = $EdgeWorker.edgeWorkerId
            if(!$EdgeWorkerID){
                throw "EdgeWorker $Name not found"
            }
        }
        catch{
            throw $_.Exception
        }
    }

    $DateTimeMatch = '[\d]{4}-[\d]{2}-[\d]{2}T[\d]{2}:[\d]{2}:[\d]{2}Z'
    if($Start -notmatch $DateTimeMatch -or $End -notmatch $DateTimeMatch){
        throw "ERROR: Start & End must be in the format 'YYYY-MM-DDThh:mm:ssZ'"
    }

    $Path = "/edgeworkers/v1/reports/$ReportID`?start=$Start&edgeWorker=$EdgeWorkerID&end=$End&status=$Status&eventHandler=$EventHandler&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}