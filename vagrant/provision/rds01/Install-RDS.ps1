Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Install RDS features
Add-WindowsFeature -Name 'Remote-Desktop-Services' -IncludeAllSubFeature -IncludeManagementTools