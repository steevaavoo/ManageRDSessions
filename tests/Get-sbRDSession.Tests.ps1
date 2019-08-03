# PSScriptRoot is a Script Variable - so you cannot F8 this.
# Also make sure to keep to the standard Repo Structure e.g.
<#
.\<Repo Root>
        ├───ModuleName
            ├───Module.psm1
            ├───Module.psd1
    ├───tests
        ├───Get-Example.Tests.ps1
 #>

$ProjectRoot = Resolve-Path "$PSScriptRoot\.."
$ModuleRoot = Split-Path (Resolve-Path "$ProjectRoot\*\*.psd1")
$ModuleName = Split-Path $ModuleRoot -Leaf
$ModulePath = (Join-Path $ModuleRoot "$ModuleName.psd1")
Import-Module $ModulePath -Force

# When testing against an entire module, make sure to specify Module Scope
InModuleScope $ModuleName {
    Describe "Get-sbRDSession" {
        Mock Get-RdUserSession { return 1 } -ModuleName $ModuleName
        It "gets all rdsessions from the RDS session collection" {
            Get-sbRDSession
            Assert-MockCalled Get-RdUserSession -Exactly 1 -Scope It
        }

        It "only accepts active, idle, disconnected, connected or any" {
            { Get-sbRDSession -SessionState Dancing } | Should Throw
        }

    }
    
    Describe "Send-sbRDMessage" {
        Mock Send-RDUserMessage { return 1 } -ModuleName $ModuleName
        It "sends a message to piped in session" {
            $testsession = Get-sbRDSession -IncludeSelf 
            $testsession | Send-sbRDMessage -MessageTitle "Test" -MessageBody "Test" -Confirm:$false
            Assert-MockCalled Send-RDUserMessage -Times 1 -Scope It
        }
       
    }

} #in modulescope