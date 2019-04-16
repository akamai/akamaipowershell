function Get-PropertyByName
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PropertyName,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    try {
        $Properties = Get-AllProperties -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Properties | where {$_.propertyName -eq $PropertyName}
    }
    catch {
        throw $_.Exception
    }
}

