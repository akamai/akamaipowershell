function Get-AKCredentialsFromRC
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $ConfigFile = '~\.edgerc'
    )

    if(!(Test-Path $ConfigFile))
    {
        Write-Host -ForegroundColor Red "ConfigFile $ConfigFile not found"
        return $false
    }

    $Config = Get-Content $ConfigFile
    if("[$Section]" -notin $Config)
    {
        Write-Host -ForegroundColor Red "Config section [$Section] not found in $ConfigFile"
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

