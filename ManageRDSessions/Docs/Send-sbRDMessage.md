---
external help file: ManageRDSessions-help.xml
Module Name: ManageRDSessions
online version:
schema: 2.0.0
---

# Send-sbRDMessage

## SYNOPSIS
Send a message to one or more Remote Desktop sessions.

## SYNTAX

```
Send-sbRDMessage [-MessageTitle] <String> [-MessageBody] <String> [-RDSession] <Object[]> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
This cmdlet, which requires objects passed in from the `Get-sbRDSession` cmdlet, will send a specified message to
the specified session(s).

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-sbRDSession <parameters> | Send-sbRDMessage -MessageTitle 'Please Save your Work' -MessageBody 'This
server will be rebooted in 5 minutes, to prevent loss of work, please save and close your work immediately.'
```

Sends a warning message concerning a server restart to all sessions passed from `Get-sbRDSession`.

## PARAMETERS

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MessageBody
The main body of the message to send.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Body

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MessageTitle
The title of the message to send.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Title

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RDSession
Requires an object passed by `Get-sbRDSession`.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Object[]

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Remove-sbRDSession](Remove-sbRDSession.md)

[Disconnect-sbRDSession](Disconnect-sbRDSession.md)

[Get-sbRDSession](Get-sbRDSession.md)
