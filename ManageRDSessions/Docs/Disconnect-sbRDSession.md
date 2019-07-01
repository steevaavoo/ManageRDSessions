---
external help file: ManageRDSessions-help.xml
Module Name: ManageRDSessions
online version: 0.1.0
schema: 2.0.0
---

# Disconnect-sbRDSession

## SYNOPSIS
Disconnect one or more Remote Desktop sessions.

## SYNTAX

```
Disconnect-sbRDSession [-RDSession] <Object[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet - which requires objects passed in from the `Get-sbRDSession` cmdlet - will disconnect any
Remote Desktop session passed to it from the pipeline.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-sbRDSession <parameters> | Disconnect-sbRDSession
```

Disconnect the Remote Desktop session(s) passed from Get-sbRDSession.

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

### -RDSession
Requires an object passed by `Get-sbRDSession`.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
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

### System.Object

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Remove-sbRDSession](Remove-sbRDSession.md)

[Send-sbRDMessage](Send-sbRDMessage.md)

[Get-sbRDSession](Get-sbRDSession.md)
