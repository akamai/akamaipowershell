function Get-AKCredentialsFromRC
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default'
    )

    if(!(Test-Path $EdgeRCFile))
    {
        Write-Host -ForegroundColor Red "EdgeRCFile $EdgeRCFile not found"
        return $false
    }

    $Config = Get-Content $EdgeRCFile
    if("[$Section]" -notin $Config)
    {
        Write-Host -ForegroundColor Red "Config section [$Section] not found in $EdgeRCFile"
        return $false
    }

    $Credentials = New-Object -TypeName PSCustomObject

    $ConfigIndex = [array]::indexof($Config,"[$Section]")
    $SectionArray = $Config[$ConfigIndex..($ConfigIndex + 4)]
    $SectionArray | foreach {
        if($_.Contains("="))
        {
            $AttrName = $_.Substring(0, $_.IndexOf("=")).Trim()
            $AttrValue = $_.Substring($_.IndexOf("=") + 1).Trim()
            $Credentials | Add-Member -MemberType NoteProperty -Name $AttrName -Value $AttrValue
        }
    }

    return $Credentials
}

