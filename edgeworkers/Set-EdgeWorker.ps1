function Set-EdgeWorker
{
    [CmdletBinding(DefaultParameterSetName = 'name')]
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $Name,
        [Parameter(ParameterSetName="id", Mandatory=$true)]    [string] $EdgeWorkerID,
        [Parameter(Mandatory=$false)] [string] $NewName,
        [Parameter(Mandatory=$true)]  [string] $GroupID,
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

    $Path = "/edgeworkers/v1/ids/$EdgeWorkerID`?accountSwitchKey=$AccountSwitchKey"

    ### Set body to update name
    if($NewName){
        $Name = $NewName
    }
    ### Use old name if NewName missing
    else{
        if(!$Name){
            $EdgeWorker = Get-EdgeWorker -EdgeWorkerID $EdgeWorkerID -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            $Name = $EdgeWorker.name
        }
    }

    $BodyObj = @{
        name = $Name
        groupId = $GroupID
    }
    $Body = $BodyObj | ConvertTo-Json

    try {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}