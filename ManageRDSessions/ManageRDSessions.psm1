#Requires -RunAsAdministrator
#Requires -Modules RemoteDesktop

function Get-sbRDSession {
    <#
    .SYNOPSIS
        Get current sessions in a Remote Desktop Services deployment.
    .DESCRIPTION
        This cmdlet will return all Sessions in the current Remote Desktop Services deployment. Narrow results by user,
        or by a combination of minimum number of Idle Session minutes, Session State (Active, Disconnected, etc.) and choose
        whether to include yourself (the Admin user).
    .PARAMETER SessionState
        Returns only Remote Desktop sessions matching the specified State.
        Accepts: Active, Any, Connected, Disconnected or Idle.
    .PARAMETER IncludeSelf
        When enabled, this parameter will include the current (console) user within any matching search results. The
        current user is omitted by default as we don't normally want to send messages to/disconnect/log off ourselves.
    .PARAMETER MinimumIdleMins
        Specifies the minimum number of minutes for which each returned Remote Desktop should have been idle.
    .PARAMETER UserName
        Returns only Remote Desktop sessions matching the specified user name(s).
    .EXAMPLE
        Get-sbRDSession

        Returns all Remote Desktop sessions, regardless of status.
    .EXAMPLE
        Get-sbRDSession -IncludeSelf

        Returns all Remote Desktop sessions including the current (console) user.
    .EXAMPLE
        Get-sbRDSession -SessionState Disconnected

        Returns all Remote Desktop sessions which are currently disconnected.
    .EXAMPLE
        Get-sbRDSession -MinimumIdleMins 1

        Returns all Remote Desktop sessions which have been idle for at least 1 minute.
    .EXAMPLE
        Get-sbRDSession -UserName steve.baker,administrator

        Returns the session information for (a) specific user(s). This cannot be used in combination with other parameters.
    .EXAMPLE
        Get-sbRDSession -SessionState Disconnected -MinimumIdleMins 25

        Returns all disconnected Remote Desktop sessions which have been idle for at least 25 minutes.
    #>

    [OutputType('Custom.SB.RDSession')]
    param(
        [CmdletBinding()]
        [Parameter(Mandatory = $false)]
        [Alias("RdsServer")]
        [string]$ConnectionBroker,
        [Parameter(Mandatory = $false)]
        [ValidateSet("Active", "Idle", "Connected", "Disconnected", "Any")]
        [Alias("State")]
        [string]$SessionState = "Any",

        # Switch to choose to include self - as we probably don't want to disconnect/logoff our own session, but
        # might want to test a message as an example - however, using the UserName parameter will allow current
        # user to be returned - which makes sense to me
        [Parameter(Mandatory = $false)]
        [Alias("Self")]
        [switch]$IncludeSelf,

        # Allowing choice to skip initial connection check to RDS Deployment to speed things up.
        [Parameter(Mandatory = $false)]
        [switch]$SkipCheck,

        [Parameter(Mandatory = $false)]
        [int]$MinimumIdleMins = 0,

        [Parameter(Mandatory = $false)]
        [Alias("Name")]
        [string[]]$UserName = $null
    )

    Begin {
        if (-not($ConnectionBroker)) {
            Write-Verbose "[BEGIN  :] No Connection Broker specified, querying and connecting to local host FQDN."
            $computerinfo = Get-CimInstance -ClassName Win32_ComputerSystem
            $ConnectionBroker = "$($computerInfo.DNSHostName).$($computerInfo.Domain)"
        }

        # Attempt to append current domain name when only NetBIOS name specified.
        if ($ConnectionBroker -notmatch "\.") {
            Write-Verbose "[BEGIN  :] [$ConnectionBroker] not a FQDN. Attempting to append [$($computerinfo.Domain)]"
            $ConnectionBroker = "$($ConnectionBroker).$($computerInfo.Domain)"
            Write-Verbose "[BEGIN  :] Constructed FQDN [$ConnectionBroker], proceeding... "
        }

        if ($SkipCheck.IsPresent) {
            Write-Verbose "[BEGIN  :] Skipping connection check..."
        } else {

            Write-Verbose "[BEGIN  :] Connection Broker [$ConnectionBroker] specified. Checking for RDS Deployment..."
            try {
                Get-RDServer -ConnectionBroker $ConnectionBroker -ErrorAction Stop | Out-Null
            } catch {
                Write-Warning "[BEGIN  :] No RDS Deployment found at [$ConnectionBroker]."
                throw
            }
            Write-Verbose "[BEGIN  :] Found RDS deployment at [$ConnectionBroker]."
        }
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

        $sessionParams = @{
            ConnectionBroker = $ConnectionBroker
        }

        if ($UserName) {
            Write-Verbose "[PROCESS:] Querying RD Session Collection for users like [$UserName]"
            $sessions = foreach ($user in $UserName) {
                Get-RDUserSession @sessionParams | Where-Object {
                    $_.UserName -like "*$user*"
                }
            }#foreach user
        } else {
            if ($IncludeSelf) {
                Write-Verbose "[PROCESS:] Querying RD Session Collection for [$SessionState] sessions - including [$env:USERNAME]"
                $sessions = Get-RDUserSession @sessionParams | Where-Object {
                    $_.SessionState -like $stateLookup.$SessionState -and ( $_.IdleTime / 60000 ) -ge $MinimumIdleMins
                }
            } else {
                Write-Verbose "[PROCESS:] Querying RD Session Collection for [$SessionState] sessions"
                $sessions = Get-RDUserSession @sessionParams | Where-Object {
                    $_.SessionState -like $stateLookup.$SessionState -and ( $_.IdleTime / 60000 ) -ge $MinimumIdleMins -and $_.UserName -ne "$env:USERNAME"
                }
            }
        } #if IncludeSelf


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
} #function

# Adding a Script Method to Get-sbRDSession to allow sending messages to the session(s) found.
$myType = "Custom.SB.RDSession"
Update-TypeData -TypeName $myType -MemberType ScriptMethod -MemberName SendMessage -Value {
    param([string]$MessageTitle, [string]$MessageBody)
    $messageParams = @{
        Hostserver       = $this.HostServer
        UnifiedSessionId = $this.UnifiedSessionId
        MessageTitle     = $MessageTitle
        MessageBody      = $MessageBody
    }
    Write-Verbose "[PROCESS:] Sending message to $($session.UserName)"
    Send-RDUserMessage @messageParams
} -force


function Disconnect-sbRDSession {
    <#
    .SYNOPSIS
        Disconnect one or more Remote Desktop sessions.
    .DESCRIPTION
        This cmdlet - which requires objects passed in from the 'Get-sbRDSession' cmdlet - will disconnect any
        Remote Desktop session passed to it from the pipeline.
    .PARAMETER RDSession
        Requires an object passed by 'Get-sbRDSession'.
    .EXAMPLE
        Get-sbRDSession <parameters> | Disconnect-sbRDSession

        Disconnect the Remote Desktop session(s) passed from Get-sbRDSession.
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        # Accepting Pipeline ByValue and requiring custom Type - also added [Object[]] to make an array, because this,
        # when supported by a ForEach block in the receiving Function's Process block, will allow someone to output
        # the objects to a variable, then pass that variable in to the receiving function.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSTypeName("Custom.SB.RDSession")][Object[]]$RDSession
    )

    # Process block is required when receiving objects from the pipeline, otherwise only last object will be received
    Process {
        # ForEach needed in order to process an array of objects passed in as a variable, as opposed to the Pipeline which feeds objects individually
        foreach ( $session in $RDSession ) {
            if ($PSCmdlet.ShouldProcess("RDUser: [$($session.Username)] with Session ID [$($session.UnifiedSessionID)]", "Disconnect")) {

                $params = @{
                    'HostServer'       = $session.HostServer
                    'UnifiedSessionID' = $session.UnifiedSessionID
                    'ErrorAction'      = 'Stop'
                    'Force'            = $true
                }

                Write-Verbose "Attempting Disconnect of $($session.Username) on $($session.HostServer)"
                Disconnect-RDUser @params
                Write-Host "User [$($session.Username)] Disconnected from [$($session.HostServer)]"
            } #shouldprocess

        } #foreach
    } #Process
} #function

function Remove-sbRDSession {
    <#
    .SYNOPSIS
        Logs Off any Remote Desktop sessions passed in by the 'Get-sbRDSession' cmdlet.
    .DESCRIPTION
        This cmdlet - which requires objects passed in from the 'Get-sbRDSession' cmdlet - will log off any
        Remote Desktop session passed to it from the pipeline.
    .PARAMETER RDSession
        Requires an object passed by 'Get-sbRDSession'.
    .PARAMETER AsJob
        Run the session log offs as background jobs, in parallel.
    .EXAMPLE
        Get-sbRDSession <parameters> | Remove-sbRDSession -AsJob
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        # Accepting Pipeline ByValue and requiring custom Type - also added [Object[]] to make an array, because this,
        # when supported by a ForEach block in the receiving Function's Process block, will allow someone to output
        # the objects to a variable, then pass that variable in to the receiving function.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSTypeName("Custom.SB.RDSession")][Object[]]$RDSession,
        [Parameter(Mandatory = $false)]
        [switch]$AsJob
    )

    # Process block is required when receiving objects from the pipeline, otherwise only last object will be received
    Process {
        # ForEach needed in order to process an array of objects passed in as a variable, as opposed to the Pipeline which feeds objects individually
        foreach ( $session in $RDSession ) {
            if ($PSCmdlet.ShouldProcess("RDUser: [$($session.Username)] with Session ID [$($session.UnifiedSessionID)]", "Logoff")) {

                $params = @{
                    'HostServer'       = $session.HostServer
                    'UnifiedSessionID' = $session.UnifiedSessionID
                    'ErrorAction'      = 'Stop'
                    'Force'            = $true
                }

                if ($AsJob.IsPresent) {
                    Write-Verbose "Attempting Logoff of [$($session.Username)] on [$($session.HostServer)] [AsJob]"
                    # Need to use "using:" scope here to pass local hashtable to Job function, otherwise will pass all as null
                    $sb = { Invoke-RDUserLogoff @using:params }
                    Start-Job -ScriptBlock $sb -Name "Log Off [$($session.UserName)]"
                } else {
                    Write-Verbose "Attempting Logoff of [$($session.Username)] on [$($session.HostServer)]"
                    Invoke-RDUserLogoff @params
                    Write-Host "User [$($session.Username)] logged off from [$($session.HostServer)]" -ForegroundColor Green
                } #ifasjob
            } #shouldprocess
        } #foreach
    } #Process
} #function

function Send-sbRDMessage {
    <#
    .SYNOPSIS
        Send a message to one or more Remote Desktop sessions.
    .DESCRIPTION
        This cmdlet, which requires objects passed in from the Get-sbRDSession cmdlet, will send a specified message to the
        specified session(s).
    .PARAMETER MessageTitle
        The title of the message to send.
    .PARAMETER MessageBody
        The main body of the message to send.
    .PARAMETER RDSession
        Requires an object passed by Get-sbRDSession.
    .EXAMPLE
        Get-sbRDSession <parameters> | Send-sbRDMessage -MessageTitle 'Please Save your Work' -MessageBody 'This
        server will be rebooted in 5 minutes, to prevent loss of work, please save and close your work immediately.'

        Sends a warning message concerning a server restart to all sessions passed from Get-sbRDSession.
    #>

    # Adding a WhatIf/Confirm setting because this involves messaging users in Production, so professionalism counts and this allows mistakes
    # to be avoided
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true)]
        [Alias('Title')]
        [string]$MessageTitle,

        [Parameter(Mandatory = $true)]
        [Alias('Body')]
        [string]$MessageBody,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSTypeName("Custom.SB.RDSession")][Object[]]$RDSession
    )

    # Process block is required when receiving objects from the pipeline, otherwise only last object will be received
    Process {
        # ForEach needed in order to process an array of objects passed in as a variable, as opposed to the Pipeline which feeds objects individually
        foreach ( $session in $RDSession ) {
            if ($PSCmdlet.ShouldProcess("RDUser: [$($session.UserName)] with Session ID [$($session.UnifiedSessionID)]", "Send message")) {

                $messageParams = @{
                    Hostserver       = $session.HostServer
                    UnifiedSessionId = $session.UnifiedSessionId
                    MessageTitle     = $MessageTitle
                    MessageBody      = $MessageBody
                }

                Write-Verbose "Sending message to $($session.UserName)"
                Send-RDUserMessage @messageParams
            } #shouldprocess

        } #foreach
    } #process
} #function
