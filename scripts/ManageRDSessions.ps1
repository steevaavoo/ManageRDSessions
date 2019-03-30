# Steves handy RDS Disconnected Sessions Management Script, Version 0.3.0.

#region sessiondiscovery
# Find and display all RDUserSessions which are in a state of STATE_DISCONNECTED
$sessions = Get-RDUserSession | Where-Object { $_.SessionState -eq 'STATE_DISCONNECTED' }
$sessions | Select-Object HostServer, UserName, @{ Label = 'Idle Time (Mins)'; expression = { $_.IdleTime / 60000 -as [int] } }, UnifiedSessionId, SessionState | Format-Table

# Find and display all RDUserSessions which are STATE_DISCONNECTED with an idle time longer than 60 minutes
$sessions = Get-RDUserSession | Where-Object { $_.SessionState -eq 'STATE_DISCONNECTED' -and ( $_.IdleTime / 60000 ) -gt 60 }
$sessions | Select-Object HostServer, UserName, @{ Label = 'Idle Time (Mins)'; expression = { $_.IdleTime / 60000 -as [int] } }, UnifiedSessionId, SessionState | Format-Table

# Find and display all connected RDUserSessions - use this one carefully with the following commands!
$sessions = Get-RDUserSession | Where-Object { $_.SessionState -eq 'STATE_CONNECTED' }
$sessions | Select-Object HostServer, UserName, @{ Label = 'Idle Time (Mins)'; expression = { $_.IdleTime / 60000 -as [int] } }, UnifiedSessionId, SessionState | Format-Table
#endregion


#region sessionmanagement
# Logging off all RDUserSessions currently in $sessions
foreach ( $session in $sessions ) {

    $sessionParams = @{
        HostServer       = $session.HostServer
        UnifiedSessionID = $session.UnifiedSessionId
        Force            = $false
    }
    Invoke-RDUserLogoff @sessionParams
}


# Testing Results and showing targets
foreach ( $session in $sessions ) {
    Write-Host "Targeting User [$($session.UserName)] with Unified Session Id [$($session.UnifiedSessionId)] on Host [$($session.HostServer)], Session State [$($session.SessionState)], Idle Time [$($session.IdleTime / 60000)]"
}


# Disconnect all users currently in $sessions - use with care!

foreach ( $session in $sessions ) {
    $sessionParams = @{
        HostServer       = $session.HostServer
        UnifiedSessionID = $session.UnifiedSessionId
        Force            = $false
    }
    Disconnect-RDUser @sessionParams

}


# Sending a message to all users currently in $sessions - use with care!

foreach ( $session in $sessions ) {

    $messageParams = @{
        Hostserver       = $session.HostServer
        UnifiedSessionId = $session.UnifiedSessionId
        MessageTitle     = 'Log Off Immediately!'
        MessageBody      = 'Scheduled Maintenance is due to begin on this server within 5 minutes. To avoid loss of work, save and log off immediately.'
    }

    #Write-Host "Sending Message [$($messageParams.MessageBody)] to HostServer [$($messageParams.Hostserver)], USID [$($messageParams.UnifiedSessionId)]"

    Send-RDUserMessage @messageParams
}


#endregion sessionmanagement
