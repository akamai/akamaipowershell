function Submit-ZoneDeleteRequest
{
    [CmdletBinding(DefaultParameterSetName='attributes', SupportsShouldProcess, ConfirmImpact='High')]
    Param(
        [Parameter(ParameterSetName='attributes', Mandatory, ValueFromPipeline)]  [string[]] $Zone,
        [Parameter(ParameterSetName='postbody', Mandatory)] [string] $Body,
        [Parameter(Mandatory=$false)] [switch] $BypassSafetyChecks,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    Begin {
        if ('attributes' -eq $PSCmdlet.ParameterSetName) {
            $zonesToDelete = @()
        }
    }

    Process {
        if ('attributes' -eq $PSCmdlet.ParameterSetName) {
            # The API endpoint we're using is intended for bulk-delete requests and there
            # is currently no individual delete equivalent. So we're going to collect all
            # all the zones submitted via pipeline directly and then actually submit them
            # all at once in the End{} block.
            $zonesToDelete += $Zone
        }
    }

    End {

        $Path = "/config-dns/v2/zones/delete-requests?accountSwitchKey=$AccountSwitchKey"
        if ($BypassSafetyChecks) {
            $Path += "&bypassSafetyChecks=true"
        }

        if ('attributes' -eq $PSCmdlet.ParameterSetName) {
            $deleteObject = @{ zones = @($zonesToDelete | Sort-Object -Unique) }
            $Body = $deleteObject | ConvertTo-Json

            $confirmationTarget = $deleteObject.zones -join ', '
        } else {
            $confirmationTarget = $Body
        }

        if ($PSCmdlet.ShouldProcess($confirmationTarget, 'Delete')) {
            try {
                Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
            }
            catch { throw }
        }

    }


    <#
    .SYNOPSIS
        Submits a request to delete one or more new Zones asynchronously.

    .DESCRIPTION
        Before deleting a zone from the Edge DNS system, the API makes sure Akamai servers aren’t receiving DNS requests for that zone. It also checks that the zone is not currently delegated to Akamai’s nameservers.

        An offline task deletes the new zones. The result of this operation is a request ID, that you can use to check the task’s status and view its results once it completes.
    
    .PARAMETER Zone
        The name of the zone(s) to delete.

    .PARAMETER BypassSafetyChecks
        If specified, disables the delegation checks and deletes the zones as soon as possible.

    .PARAMETER EdgeRCFile
        Path to a valid .edgerc file with authentication information.
    
    .PARAMETER Section
        The section within the .edgerc file to use for authentication.

    .PARAMETER AccountSwitchKey
        This is a feature only used by Partners and Akamai internal users.

    .EXAMPLE
        Submit-ZoneDeleteRequest -Zone example.com

        Delete the specified zone.

    .EXAMPLE
        Submit-ZoneDeleteRequest -Zone example.com,example.net -BypassSafetyChecks

        Delete the specified zones and skip the Akamai delegation checks.

    .EXAMPLE
        'example.com','example.net' | Submit-ZoneDeleteRequest -Confirm:$false

        Delete the specified zones by passing them via the pipeline and bypass confirmation prompts.
    #>
}