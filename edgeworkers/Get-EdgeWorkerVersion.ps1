function Get-EdgeWorkerVersion
{
    [CmdletBinding(DefaultParameterSetName = 'name')]
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $Name,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $EdgeWorkerID,
        [Parameter(Mandatory=$true)]  [string] $Version,
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

    if($Version.ToLower() -eq "latest"){
        try{
            $Versions = List-EdgeWorkerVersions -EdgeWorkerID $EdgeWorkerID -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            $Version = $Versions[-1].version
        }
        catch{
            throw $_.Exception
        }
    }

    $Path = "/edgeworkers/v1/ids/$EdgeWorkerID/versions/$Version`?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}