param(
    $RDHostName,
    $RDCollectionName
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module RemoteDesktop

$rdparams = @{
    ConnectionBroker = $RDHostName
    WebAccessServer  = $RDHostName
    SessionHost      = $RDHostName
}

New-RDSessionDeployment @rdparams

$lcparams = @{
    LicenseServer    = $RDHostName
    ConnectionBroker = $RDHostName
    Mode             = 'PerUser'
}

Set-RDLicenseConfiguration @lcparams -Force

$rdscparams = @{
    CollectionName = $RDCollectionName
    SessionHost    = $RDHostName
}

New-RDSessionCollection @rdscparams

New-RDRemoteApp -CollectionName $RDCollectionName -DisplayName "Notepad" -FilePath "C:\Windows\System32\Notepad.exe"
New-RDRemoteApp -CollectionName $RDCollectionName -DisplayName "Paint" -FilePath "C:\Windows\System32\mspaint.exe"