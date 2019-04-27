# Variables

$ConfigurationPath = Join-Path -Path $PSScriptRoot -ChildPath '\..\DscConfigurations\RDSLabConfiguration.ps1'
$ConfigurationDataPath = "$PSScriptRoot\RDSLabConfigData.psd1"
$ConfigurationData = Import-PowerShellDataFile -Path $ConfigurationDataPath
# $ComputerNames = $ConfigurationData.AllNodes.NodeName | Where-Object { $_ -ne "*" }
$ComputerNames = 'rds01'
$DscOutputPath = 'C:\Source\DSC\MOFs'

# Credentials
# $DomainAdminCredential = New-Object -TypeName 'PSCredential' -ArgumentList ('LAB\vagrant', (ConvertTo-SecureString -String 'vagrant' -AsPlainText -Force))
# $DSRMAdminCredential = New-Object -TypeName 'PSCredential' -ArgumentList ('LAB\vagrant', (ConvertTo-SecureString -String 'P@ssw0rd!"£' -AsPlainText -Force))
$VagrantCredential = New-Object -TypeName 'PSCredential' -ArgumentList ('vagrant', (ConvertTo-SecureString -String 'vagrant' -AsPlainText -Force))

# Load DSC configuration into memory
. $ConfigurationPath

# Compiling the RDS DSC MOF
$rdsParams = @{
    collectionName        = $ConfigurationData.Role.RemoteDesktopServer.collectionName
    collectionDescription = $ConfigurationData.Role.RemoteDesktopServer.collectionDescription
    connectionBroker      = $ConfigurationData.Role.RemoteDesktopServer.brokerFQDN
    webAccessServer       = $ConfigurationData.Role.RemoteDesktopServer.webFQDN
    # DomainAdminCredential = $DomainAdminCredential
    # DSRMAdminCredential   = $DSRMAdminCredential
    ConfigurationData     = $ConfigurationDataPath
    OutputPath            = $DscOutputPath
    Verbose               = $true
}

# write-verbose "Creating configuration with parameter values:"
# write-verbose "Collection Name: $collectionName"
# write-verbose "Collection Description: $collectionDescription"
# write-verbose "Connection Broker: $brokerFQDN"
# write-verbose "Web Access Server: $webFQDN"

# Calls the RDS "Configuration (Function)" which creates the MOF files - here "RDS" follows the term "Function" in the
# above referenced $ConfigurationPath
RemoteDesktopSessionHost @rdsParams

# Set LCM path and push configuration (looks for MOFs and applies them)
Set-DscLocalConfigurationManager -Path $DscOutputPath -ComputerName $ComputerNames -Credential $VagrantCredential -Verbose -Force
Start-DscConfiguration -Path $DscOutputPath -ComputerName $ComputerNames -Credential $VagrantCredential -Verbose -Force -Wait
