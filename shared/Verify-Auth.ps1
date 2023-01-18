function Verify-Auth
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $ReturnObject,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/-/client-api/active-grants/implicit"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        if($ReturnObject)
        {
            return $Result
        }
        Write-Host "Credential Name: $($Result.name)"
        Write-Host "---------------------------------"
        Write-Host "Created $($Result.Created) by $($Result.CreatedBy)"
        Write-Host "Updated $($Result.Updated) by $($Result.UpdatedBy)"
        Write-Host "Activated $($Result.Activated) by $($Result.ActivatedBy)"
        Write-Host "Grants:"
        
        $Scope = $Result.Scope.Split(" ")
        $Grants = New-Object System.Collections.ArrayList
        foreach($Grant in $Scope)
        {
            $Grant = $Grant.Replace("https://luna.akamaiapis.net/-/scope/","")
            $Grant = $Grant.Replace("/-/",": ")
            $Grants.Add("    $Grant") | Out-Null
        }
        $Grants
    }
    catch {
        throw $_
    }
}
