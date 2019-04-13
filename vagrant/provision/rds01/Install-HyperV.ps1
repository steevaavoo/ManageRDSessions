Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart

Install-WindowsFeature RSAT-Hyper-V-Tools -IncludeAllSubFeature

Install-WindowsFeature RSAT-Clustering -IncludeAllSubFeature

Install-WindowsFeature Multipath-IO

# Restart-Computer - handling this in Vagrantfile.

