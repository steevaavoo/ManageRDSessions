function Get-RDActiveSession {
    $sessions = Get-RDUserSession | Where-Object { $_.SessionState -eq 'STATE_ACTIVE' -or $_.SessionState -eq 'STATE_IDLE' }
    $sessions | Select-Object HostServer, UserName, UnifiedSessionId, SessionState | Format-Table
}

function Get-RDDisconnectedSession {
    [CmdletBinding()]
    param (
        [
        Parameter(
            Mandatory = $False,
            HelpMessage = "Specify minimum number of idle session minutes"
        )
        ]
        [Alias('idle')]
        [int]$MinIdleTime = 0
    )

    $sessions = Get-RDUserSession | Where-Object { $_.SessionState -eq 'STATE_DISCONNECTED' -and ( $_.IdleTime / 60000 ) -gt $MinIdleTime }
    $sessions | Select-Object HostServer, UserName, @{ Label = 'Idle Time (Mins)'; expression = {$_.IdleTime / 60000 -as [int] } }, UnifiedSessionId, SessionState | Format-Table
}

function Remove-RDDisconnectedSession {
    [CmdletBinding()]
    param (
        [
        Parameter(
            Mandatory = $False,
            HelpMessage = "Specify minimum number of idle session minutes"
        )
        ]
        [Alias('idle')]
        [int]$MinIdleTime = 0,
        [switch]$Force = $False
    )

    $sessions = Get-RDUserSession | Where-Object { $_.SessionState -eq 'STATE_DISCONNECTED' -and ( $_.IdleTime / 60000 ) -gt $MinIdleTime }

    foreach ( $session in $sessions ) {

        $sessionParams = @{
            HostServer       = $session.HostServer
            UnifiedSessionID = $session.UnifiedSessionId
            Force            = $Force
        }
        Invoke-RDUserLogoff @sessionParams
    }
}

function Disconnect-RDConnectedUserSession {
    [CmdletBinding()]
    param (
        [switch]$Force = $False
    )

    $sessions = Get-RDUserSession | Where-Object { $_.SessionState -eq 'STATE_ACTIVE' -or $_.SessionState -eq 'STATE_IDLE' }

    foreach ( $session in $sessions ) {
        $sessionParams = @{
            HostServer       = $session.HostServer
            UnifiedSessionID = $session.UnifiedSessionId
            Force            = $Force
        }
        Disconnect-RDUser @sessionParams
    }
}

function Send-RDAllUserMessage {
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