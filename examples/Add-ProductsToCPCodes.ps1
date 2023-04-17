#************************************************************************
#
#	Name: Add-ProductsToCPCodes.ps1
#	Author: S Macleod
#	Purpose: Adds Product lines to CP Code array from List-CPCodes cmdlet
#	Date: 18/02/2019
#	Version: 1 - Initial
#            2 - Updated and simplified. 3/6/20
#
#************************************************************************

Param(
        [Parameter(Mandatory=$true)]  $CPCodes,
        [Parameter(Mandatory=$true)]  [string] $ProductIDToAdd,
        [Parameter(Mandatory=$false)] [switch] $JustTesting,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = "~\.edgerc",
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

for($i = 0; $i -lt $CPCodes.count; $i++)
{
    $PercentComplete = ($i / $CPCodes.Count * 100)
    $PercentComplete = [math]::Round($PercentComplete)
    Write-Progress -Activity "Updating CP Codes..." -Status "$PercentComplete% Complete:" -PercentComplete $PercentComplete;

    $CPCode = $CPCodes[$i]
    $Detail = Get-CPCode -CPCode $CPCode.cpcodeId -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey

    if($ProductIDToAdd -notin $Detail.products.productId){
        $Detail.products += @{productId = $ProductIDToAdd}
    }
    else{
        Write-Host -ForegroundColor Yellow "Warning: CP Code $($CPCode.cpcodeId) already contains product $ProductIDToAdd. Nothing to do"
        continue
    }

    if($JustTesting)
    {
        Write-Host -ForegroundColor Green "JUST TESTING: Adding product $ProductIDToAdd to CP Code $($CPCode.cpcodeId)"
    }
    else
    {
        try
        {
            Write-Host -ForegroundColor Yellow "Adding product $ProductIDToAdd to CP Code $($CPCode.cpcodeId)"
            $Json = $Detail | ConvertTo-Json -Depth 10
            $Result = Set-CPCode -CPCode $CPCode.cpcodeId -Body $Json -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        }
        catch
        {
            Write-Host "ERROR: Failed to update CP Code $($CPCode.cpcodeId)"
            Write-Host $_
        }
    }
}
