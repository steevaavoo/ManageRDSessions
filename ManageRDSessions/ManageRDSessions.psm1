function Get-sbRDSession {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet("Active", "Idle", "Connected", "Disconnected", "Any")]
        [Alias("State")]
        [string]$SessionState = "Any",
        [Parameter(Mandatory = $false)]
        [int]$MinimumIdleTime = 0
    )

    Begin {
        # Intentionally empty
    }
    # Process block is required when outputting objects to the pipeline, otherwise only the final object will be passed
    Process {

        $state = switch ($SessionState) {
            "Active" { "STATE_ACTIVE" }
            "Idle" { "STATE_IDLE" }
            "Disconnected" { "STATE_DISCONNECTED" }
            "Connected" { "STATE_CONNECTED" }
            "Any" { "*" }
        }
        Write-Verbose "Querying RD Session Collection for $SessionState sessions"
        $sessions = Get-RDUserSession | Where-Object {
            $_.SessionState -like $state -and ( $_.IdleTime / 60000 ) -ge $MinimumIdleTime
        }

    foreach ($session in $sessions) {
        # Creating PSObject to output and naming as my own type for use in later pipeline input...
        $object = [PSCustomObject]@{
            PSTypeName       = "Custom.SB.RDSession"
            HostServer       = $session.HostServer
            UserName         = $session.UserName
            UnifiedSessionID = $session.UnifiedSessionID
            SessionState     = $session.SessionState
            IdleTime         = ($session.IdleTime / 60000 -as [int])
        } #pscustomobject

        # Outputting object
        Write-Output $object
    } #foreach
} #process

End {
    #Intentionally empty
}
} #function

function Remove-sbRDSession {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        # Accepting Pipeline ByValue and requiring custom Type - also added [Object[]] to make an array, not sure if needed
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSTypeName("Custom.SB.RDSession")][Object[]]$RDSession,
        [Parameter(Mandatory = $true)]
        [ValidateSet("LogOff", "Disconnect")]
        [string]$Action
    )

    Begin {
        # Intentionally empty
    }
    # Process block is required when receiving objects from the pipeline, otherwise only last object will be received
    Process {
        if ($PSCmdlet.ShouldProcess("RDUser: $($RDSession.Username) with Session ID $($RDSession.UnifiedSessionID)", "$Action")) {

            $params = @{
                'HostServer'       = $RDSession.HostServer
                'UnifiedSessionID' = $RDSession.UnifiedSessionID
                'ErrorAction'      = 'Stop'
                'Force'            = $true
            }

            Write-Verbose "Attempting $Action of $($RDSession.Username) on $($RDSession.HostServer)"
            switch ($Action) {
                "LogOff" {
                    Invoke-RDUserLogoff @params
                    Write-Host "User [$($RDSession.Username)] [Logged Off] from [$($RDSession.HostServer)]"
                }
                "Disconnect" {
                    Disconnect-RDUser @params
                    Write-Host "User [$($RDSession.Username)] [Disconnected] from [$($RDSession.HostServer)]"
                }
                Default { }

            }

        } #shouldprocess

    } #Process

    End {
        # Intentionally empty
    }
} #function


<# Start of multi-line comment - BELOW TO BE DEVELOPED AND ACCEPT PIPELINE INPUT
function Send-sbRDMessage {
    [CmdletBinding()]
    param (
        [
        Parameter(
            Mandatory = $true,
            HelpMessage = "Message to send to all Remote Desktop Users"
        )
        ]
        [Alias('Message')]
        [string]$MessageBody,

        [
        Parameter(
            Mandatory = $true,
            HelpMessage = "Title of the message to send"
        )
        ]
        [Alias('Title')]
        [string]$MessageTitle

    )

    $sessions = Get-RDUserSession
    foreach ( $session in $sessions ) {

        $messageParams = @{
            Hostserver       = $session.HostServer
            UnifiedSessionId = $session.UnifiedSessionId
            MessageTitle     = $MessageTitle
            MessageBody      = $MessageBody
        }

        Send-RDUserMessage @messageParams
    }
}

End of multi-line comment #>