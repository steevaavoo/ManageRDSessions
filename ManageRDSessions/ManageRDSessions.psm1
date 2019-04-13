function Get-sbRDSession {
    [OutputType('Custom.SB.RDSession')]
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet("Active", "Idle", "Connected", "Disconnected", "Any")]
        [Alias("State")]
        [string]$SessionState = "Any",

        [Parameter(Mandatory = $false)]
        [int]$MinimumIdleMins = 0
    )

    Begin {
        # Intentionally empty
    }
    # Process block is required when outputting objects to the pipeline, otherwise only the final object will be passed
    Process {
        # Variable Substitution alternative to Switch - suggested by Adam. Love this. It will convert whatever
        # is passed after $stateLookup. into the value on the right.
        $stateLookup = @{
            Active       = "STATE_ACTIVE"
            Idle         = "STATE_IDLE"
            Disconnected = "STATE_DISCONNECTED"
            Connected    = "STATE_CONNECTED"
            Any          = "*"
        }
        Write-Verbose "Querying RD Session Collection for [$SessionState] sessions"
        $sessions = Get-RDUserSession | Where-Object {
            $_.SessionState -like $stateLookup.$SessionState -and ( $_.IdleTime / 60000 ) -ge $MinimumIdleMins
        }

    foreach ($session in $sessions) {
        # Creating and Outputting PSCustomObject
        [PSCustomObject]@{
            PSTypeName       = "Custom.SB.RDSession"
            HostServer       = $session.HostServer
            UserName         = $session.UserName
            UnifiedSessionID = $session.UnifiedSessionID
            SessionState     = $session.SessionState
            IdleTime         = ($session.IdleTime / 60000 -as [int])
        }
    }
} #process

End {
    #Intentionally empty
}
} #function

function Remove-sbRDSession {
    # TO SPLIT INTO 2 DIVERSE FUNCTIONS - trying to do too much (see project)
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        # Accepting Pipeline ByValue and requiring custom Type - also added [Object[]] to make an array, because this,
        # when supported by a ForEach block in the receiving Function's Process block, will allow someone to output
        # the objects to a variable, then pass that variable in to the receiving function.
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
        # ForEach needed in order to process an array of objects passed in as a variable, as opposed to the Pipeline which feeds objects individually
        foreach ( $session in $RDSession ) {
            if ($PSCmdlet.ShouldProcess("RDUser: [$($session.Username)] with Session ID [$($session.UnifiedSessionID)]", "[$Action]")) {

                $params = @{
                    'HostServer'       = $session.HostServer
                    'UnifiedSessionID' = $session.UnifiedSessionID
                    'ErrorAction'      = 'Stop'
                    'Force'            = $true
                }

                Write-Verbose "Attempting $Action of $($session.Username) on $($session.HostServer)"
                switch ($Action) {
                    "LogOff" {
                        Invoke-RDUserLogoff @params
                        Write-Host "User [$($session.Username)] [Logged Off] from [$($session.HostServer)]"
                    }
                    "Disconnect" {
                        Disconnect-RDUser @params
                        Write-Host "User [$($session.Username)] [Disconnected] from [$($session.HostServer)]"
                    }
                    Default { }

                }

            } #shouldprocess
        } #foreach
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