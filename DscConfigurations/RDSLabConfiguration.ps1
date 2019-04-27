Configuration RemoteDesktopSessionHost
{
    param
    (

        # Connection Broker Name
        [Parameter(Mandatory)]
        [String]$collectionName,

        # Connection Broker Description
        [Parameter(Mandatory)]
        [String]$collectionDescription,

        # Connection Broker Node Name
        [String]$connectionBroker,

        # Web Access Node Name
        [String]$webAccessServer
    )
    Import-DscResource -Module xRemoteDesktopSessionHost

    Node $AllNodes.NodeName
    {
        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        if ($Node.Role -contains 'RemoteDesktopServer') {
            $rdsHostname = $Node.NodeName
            if (!$connectionBroker) {$connectionBroker = $rdsHostname}
            if (!$connectionWebAccessServer) {$webAccessServer = $rdsHostname}

            WindowsFeature Remote-Desktop-Services {
                Ensure = "Present"
                Name   = "Remote-Desktop-Services"
            }

            WindowsFeature RDS-RD-Server {
                Ensure = "Present"
                Name   = "RDS-RD-Server"
            }

            # WindowsFeature Desktop-Experience {
            #     Ensure = "Present"
            #     Name   = "Desktop-Experience"
            # }

            WindowsFeature RSAT-RDS-Tools {
                Ensure               = "Present"
                Name                 = "RSAT-RDS-Tools"
                IncludeAllSubFeature = $true
            }

            if ($rdsHostname -eq $connectionBroker) {
                WindowsFeature RDS-Connection-Broker {
                    Ensure = "Present"
                    Name   = "RDS-Connection-Broker"
                }
            }

            if ($rdsHostname -eq $webAccessServer) {
                WindowsFeature RDS-Web-Access {
                    Ensure = "Present"
                    Name   = "RDS-Web-Access"
                }
            }

            WindowsFeature RDS-Licensing {
                Ensure = "Present"
                Name   = "RDS-Licensing"
            }

            xRDSessionDeployment Deployment {
                SessionHost      = $rdsHostname
                ConnectionBroker = if ($ConnectionBroker) {$ConnectionBroker} else {$rdsHostname}
                WebAccessServer  = if ($WebAccessServer) {$WebAccessServer} else {$rdsHostname}
                DependsOn        = "[WindowsFeature]Remote-Desktop-Services", "[WindowsFeature]RDS-RD-Server"
            }

            xRDSessionCollection Collection {
                CollectionName        = $collectionName
                CollectionDescription = $collectionDescription
                SessionHost           = $rdsHostname
                ConnectionBroker      = if ($ConnectionBroker) {$ConnectionBroker} else {$rdsHostname}
                DependsOn             = "[xRDSessionDeployment]Deployment"
            }
            xRDSessionCollectionConfiguration CollectionConfiguration {
                CollectionName                = $collectionName
                CollectionDescription         = $collectionDescription
                ConnectionBroker              = if ($ConnectionBroker) {$ConnectionBroker} else {$rdsHostname}
                TemporaryFoldersDeletedOnExit = $false
                SecurityLayer                 = "SSL"
                DependsOn                     = "[xRDSessionCollection]Collection"
            }
            xRDRemoteApp Calc {
                CollectionName = $collectionName
                DisplayName    = "Calculator"
                FilePath       = "C:\Windows\System32\calc.exe"
                Alias          = "calc"
                DependsOn      = "[xRDSessionCollection]Collection"
            }
            xRDRemoteApp Mstsc {
                CollectionName = $collectionName
                DisplayName    = "Remote Desktop"
                FilePath       = "C:\Windows\System32\mstsc.exe"
                Alias          = "mstsc"
                DependsOn      = "[xRDSessionCollection]Collection"
            }
        } #if rds node
    }
}
