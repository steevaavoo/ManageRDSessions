@{
    AllNodes    = @(

        # This will be run on all nodes
        @{
            NodeName                    = '*'
            # Local Configuration Manager
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
            DebugMode                   = 'All'
            RebootNodeIfNeeded          = $true
        }

        # DC01 Node
        @{
            NodeName = 'dc01'
            # Wrap in an array for consistency
            Role     = @('DomainController')
        }

        # RDS01 Node
        @{
            NodeName = 'rds01'
            # Wrap in an array for consistency
            Role     = @('RemoteDesktopServer')
        }

    )

    # Define role data here to ensure role and node are not tightly coupled
    Role        = @{
        RemoteDesktopServer = @{
            brokerFQDN            = 'rds01.lab.milliondollar.me.uk'
            webFQDN               = 'rds01.lab.milliondollar.me.uk'
            collectionName        = 'Million Dollar Session Collection'
            collectionDescription = 'This is a session collection :|'
        }

        DomainController    = @{
            DomainName          = 'lab.milliondollar.me.uk'
            NetBIOSName         = 'LAB'
            AdGroups            = 'Information Technology'
            OrganizationalUnits = 'Information Technology'
            AdUsers             = @(
                @{
                    FirstName  = 'Steve'
                    LastName   = 'Baker'
                    UserName   = 'Steve.Baker'
                    Department = 'Information Technology'
                    Title      = 'Manager of IT'
                }
                @{
                    FirstName  = 'Adam'
                    LastName   = 'Rush'
                    UserName   = 'Adam.Rush'
                    Department = 'Information Technology'
                    Title      = 'King of IT'
                }
                @{
                    FirstName  = 'Phil'
                    LastName   = 'Changeur'
                    UserName   = 'Phil.Changeur'
                    Department = 'Information Technology'
                    Title      = 'Proof Reader'
                }
            )
        }
    }

    # Parameters shared across multiple nodes
    NonNodeData = @{
        # WinSXS Sources
        WinSxsSource     = 'C:\Source\Win2016-ISO-Sources-sxs'

        # Wait resource parameters
        RetryCount       = 50
        RetryIntervalSec = 30
    }
}
