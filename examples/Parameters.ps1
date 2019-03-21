# Example of Parameter Block Usage

# CmdletBinding enables "advanced" features such as the -Verbose switch when running a script/function
[CmdletBinding()]
param (
    [
    Parameter(
        Mandatory = $True,
        HelpMessage = "Something to help explain the parameter to the user"
    )
    ]
    [Alias('HostName')] # Declaring an alias for the parameter - these lines are called "decorations"
    [string]$VariableOneName, # Commas after every parameter but the last one

    [ValidateSet(2, 3)] # Validating the parameter - command fails if the input doesn't match
    [int]$DriveType = 3 # Declaring as an integer and assigning a default value
)
