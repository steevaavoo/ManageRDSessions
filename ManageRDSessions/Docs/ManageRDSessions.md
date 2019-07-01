---
Module Name: ManageRDSessions
Module Guid: 877182f5-297e-44fa-af26-567d60221e91
Download Help Link: https://bit.ly/2xghizR
Help Version: 0.1.0
Locale: en-US
---

### [Get-sbRDSession](Get-sbRDSession.md)
Returns all Sessions in the current Remote Desktop Services deployment. Narrow results by user, or
by a combination of minimum number of Idle Session minutes, Session State (Active, Disconnected, etc.) and choose whether to include yourself (the Admin user).

Must be run on a Remote Desktop Services Session Host server.

Returns a Custom Object which can be passed to the session management/interaction cmdlets contained
within the ManageRDSessions module.

# ManageRDSessions Module
## Description
This module simplifies management of Remote Desktop sessions in a Remote Desktop deployment. Using the included
cmdlets you can query sessions based on idle time, status and pass the results to cmdlets to disconnect, log off,
or send messages to the session.

## ManageRDSessions Cmdlets
### [Disconnect-sbRDSession](Disconnect-sbRDSession.md)
Disconnects the Remote Desktop session(s) passed along the pipeline from `Get-sbRDSession`.


### [Remove-sbRDSession](Remove-sbRDSession.md)
Logs off the Remote Desktop session(s) passed along the pipeline from `Get-sbRDSession`.

### [Send-sbRDMessage](Send-sbRDMessage.md)
Sends a specified message to the Remote Desktop session(s) passed along the pipeline from `Get-sbRDSession`.

