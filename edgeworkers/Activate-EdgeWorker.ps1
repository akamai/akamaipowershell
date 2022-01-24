function Activate-EdgeWorker
{
    [CmdletBinding(DefaultParameterSetName = 'name')]
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $Name,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $EdgeWorkerID,
        [Parameter(Mandatory=$true)]  [string] $Version,
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('STAGING','PRODUCTION')] $Network,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($Name){
        try{
            $EdgeWorker = (List-EdgeWorkers -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey) | Where {$_.name -eq $Name}
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

    $Path = "/edgeworkers/v1/ids/$EdgeWorkerID/activations?accountSwitchKey=$AccountSwitchKey"

    $BodyObj = @{
        network = $Network
        version = $Version
    }
    $Body = $BodyObj | ConvertTo-Json

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}