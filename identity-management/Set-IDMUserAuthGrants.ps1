function Set-IDMUserAuthGrants
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $UiIdentityID,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)]  [object[]] $AuthGrants,
        [Parameter(Mandatory=$true,ParameterSetName='postbody')]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    <#
        Cmdlet broken down into begin, process and end in order to reconstruct pipelined array, which is split out by Powershell into multiple
        single items with the Process section executing for each one.
    #>

    begin{
        $Path = "/identity-management/v2/user-admin/ui-identities/$UiIdentityID/auth-grants"
        if($PSCmdlet.ParameterSetName -eq 'pipeline'){
            $CombinedAuthGrantsArray = New-Object -TypeName System.Collections.ArrayList
        }
    }

    process{
        foreach($Grant in $AuthGrants){
            $CombinedAuthGrantsArray.Add($Grant) | Out-Null
        }
    }

    end{
        if($PSCmdlet.ParameterSetName -eq 'pipeline'){
            $Body = $CombinedAuthGrantsArray | ConvertTo-Json -Depth 100 -AsArray
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            return $Result
        }
        catch {
            throw $_
        }
    }
}
