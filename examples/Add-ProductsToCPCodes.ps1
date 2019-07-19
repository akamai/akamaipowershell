#************************************************************************
#
#	Name: Add-ProductsToCPCodes.ps1
#	Author: S Macleod
#	Purpose: Adds Product lines to CP Code array
#	Date: 18/02/2019
#	Version: 1 - Initial
#
#************************************************************************

Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$true)]  [string] $AccountSwitchKey,
        [Parameter(Mandatory=$true)]  [int[]]  $CPCodes,
        [Parameter(Mandatory=$true)]  [string] $ProductIDToAdd,
        [Parameter(Mandatory=$false)] [switch] $JustTesting
    )

if(!(Get-Module AkamaiPowershell))
{
    Write-Host -ForegroundColor Yellow "Please import the Akamai Powershell module before running this script"
    return
}

foreach($CPCode in $CPCodes)
{
    if($AccountSwitchKey)
    {
        $Detail = Get-CPCode -Section $Section -AccountSwitchKey $AccountSwitchKey -CPCode $CPCode
    }
    else
    {
        $Detail = Get-CPCode -Section $Section -CPCode $CPCode
    }

    if($Detail.products[0].productId -ne $ProductIDToAdd)
    {
        $Detail.products += @{productId = $ProductIDToAdd}
    }

    if($JustTesting)
    {
        Write-Host -ForegroundColor Green "JUST TESTING: Adding product $ProductIDToAdd to CP Code $CPCode"
    }
    else
    {
        try
        {
            Write-Host "Adding product $ProductIDToAdd to CP Code $CPCode"
            $Json = $Detail | ConvertTo-Json -Depth 10
            if($AccountSwitchKey)
            {
                $Result = Set-CPCode -Section $Section -AccountSwitchKey $AccountSwitchKey -CPCode $CPCode -Body $Json
            }
            else
            {
                $Result = Set-CPCode -Section $Section -CPCode $CPCode -Body $Json
            }
            return $Result
        }
        catch
        {
            Write-Host "ERROR: Failed to update CP Code $CPCode"
            Write-Host $_
            return
        }
    }
}