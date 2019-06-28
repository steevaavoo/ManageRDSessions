---
external help file: ManageRDSessions-help.xml
Module Name: ManageRDSessions
online version: 0.1.0
schema: 2.0.0
---

# Get-sbRDSession

## SYNOPSIS
Get current sessions in a Remote Desktop Services deployment.

## SYNTAX

### State (Default)
```
Get-sbRDSession [-SessionState <String>] [-IncludeSelf] [-MinimumIdleMins <Int32>] [<CommonParameters>]
```

### UserName
```
Get-sbRDSession [-UserName <String>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will return all Sessions in the current Remote Desktop Services deployment. Narrow results by user, or
by a combination of minimum number of Idle Session minutes, Session State (Active, Disconnected, etc.) and choose whether to include yourself (the Admin user).

Must be run on a Remote Desktop Services Session Host server.

Returns a Custom Object which can be passed to the session management/interaction cmdlets contained
within the ManageRDSessions module.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-sbRDSession


HostServer       : rds01.lab.milliondollar.me.uk
UserName         : steve.baker
UnifiedSessionID : 3
SessionState     : STATE_ACTIVE
IdleTime         : 0
```

Getting all Remote Desktop sessions, regardless of status.

### Example 2
```powershell
PS C:\> Get-sbRDSession -IncludeSelf


HostServer       : rds01.lab.milliondollar.me.uk
UserName         : administrator
UnifiedSessionID : 2
SessionState     : STATE_ACTIVE
IdleTime         : 0

HostServer       : rds01.lab.milliondollar.me.uk
UserName         : steve.baker
UnifiedSessionID : 3
SessionState     : STATE_ACTIVE
IdleTime         : 0
```

Getting all Remote Desktop sessions including the current (console) user.

### Example 3
```powershell
PS C:\> Get-sbRDSession -SessionState Disconnected


HostServer       : rds01.lab.milliondollar.me.uk
UserName         : steve.baker
UnifiedSessionID : 3
SessionState     : STATE_DISCONNECTED
IdleTime         : 1
```

Getting all Remote Desktop sessions which are currently disconnected.

### Example 4
```powershell
PS C:\> Get-sbRDSession -MinimumIdleMins 1


HostServer       : rds01.lab.milliondollar.me.uk
UserName         : steve.baker
UnifiedSessionID : 3
SessionState     : STATE_DISCONNECTED
IdleTime         : 3
```

Getting all Remote Desktop sessions which have been idle for at least 1 minute.

### Example 5
```powershell
PS C:\> Get-sbRDSession -UserName steve.baker,administrator


HostServer       : rds01.lab.milliondollar.me.uk
UserName         : steve.baker
UnifiedSessionID : 3
SessionState     : STATE_DISCONNECTED
IdleTime         : 20

HostServer       : rds01.lab.milliondollar.me.uk
UserName         : administrator
UnifiedSessionID : 2
SessionState     : STATE_ACTIVE
IdleTime         : 0
```

Getting the session information for (a) specific user(s). This cannot be used in combination with other parameters.

### Example 6
```powershell
PS C:\> Get-sbRDSession -SessionState Disconnected -MinimumIdleMins 25


HostServer       : rds01.lab.milliondollar.me.uk
UserName         : roger.jenkins
UnifiedSessionID : 2
SessionState     : STATE_DISCONNECTED
IdleTime         : 43

HostServer       : rds01.lab.milliondollar.me.uk
UserName         : steve.baker
UnifiedSessionID : 8
SessionState     : STATE_DISCONNECTED
IdleTime         : 51
```

Getting all disconnected Remote Desktop sessions which have been idle for at least 25 minutes.

## PARAMETERS

### -IncludeSelf
When enabled, this parameter will include the current (console) user within any matching search results. The
current user is omitted by default as we don't normally want to send messages to/disconnect/log off ourselves.

```yaml
Type: SwitchParameter
Parameter Sets: State
Aliases: Self

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinimumIdleMins
Specifies the minimum number of minutes for which each returned Remote Desktop should have been idle.

```yaml
Type: Int32
Parameter Sets: State
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SessionState
Returns only Remote Desktop sessions matching the specified State.

```yaml
Type: String
Parameter Sets: State
Aliases: State
Accepted values: Active, Idle, Connected, Disconnected, Any

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserName
Returns only Remote Desktop sessions matching the specified user name(s)

```yaml
Type: String
Parameter Sets: UserName
Aliases: Name

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### Custom.SB.RDSession

## NOTES

## RELATED LINKS

[Remove-sbRDSession](Remove-sbRDSession.md)

[Disconnect-sbRDSession](Disconnect-sbRDSession.md)

[Send-sbRDMessage](Send-sbRDMessage.md)

[Online Help](https://bit.ly/2xghizR)
