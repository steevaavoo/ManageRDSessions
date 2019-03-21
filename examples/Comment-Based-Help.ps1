<# 
.SYNOPSIS
Get-DiskInventory retrieves logical disk information from one or more computers.
.DESCRIPTION
Get-DiskInventory uses WMI to retrieve the Win32_LogicalDisk instances from one or more computers. It displays each disk's drive letter, free space, total size and percentage of free space.
.PARAMETER ComputerName
The computer name, or names, to query. Default: localhost.
.PARAMETER DriveType
The drive type to query. See Win32_LogicalDisk documentation for values. 3 is a fixed disk, and is the default.
.EXAMPLE
Get-DiskInventory -ComputerName COMPUTER-NAME -DriveType 3
Queries the computer "COMPUTER-NAME" for all Fixed Disks and displays their details.
#>
