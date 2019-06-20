function Get-PropertyByName
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PropertyName,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    try {
        $Property = Find-Property -PropertyName $PropertyName -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Property
    }
    catch {
        throw $_.Exception
    }
}

