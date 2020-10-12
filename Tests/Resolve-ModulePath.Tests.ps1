. (Join-Path $PSScriptRoot Test.Setup.ps1)

Describe "Resolve-ModulePath" {

    Context Default {

        BeforeAll {
            Mock Get-Module -ModuleName $Module -ParameterFilter {$FullyQualifiedName.Name -eq 'ImportedModule' -and -not $ListAvailable} {
                return @{ModuleBase = 'C:\Modules\foo\1.2.3'}
            }

            Mock Get-Module -ModuleName $Module -ParameterFilter {$FullyQualifiedName.Name -eq 'InstalledModule' -and -not $ListAvailable} {
                return
            }

            Mock Get-Module -ModuleName $Module -ParameterFilter {$FullyQualifiedName.Name -eq 'ImportedModule' -and $ListAvailable} {
                throw "Should have pulled from the session!"
            }

            Mock Get-Module -ModuleName $Module -ParameterFilter {$FullyQualifiedName.Name -eq 'InstalledModule' -and $ListAvailable} {
                return @{ModuleBase = 'C:\Modules\foo\1.2.3'}
            }

            Mock Get-Module -ModuleName $Module -ParameterFilter {$FullyQualifiedName.Name -eq '.\InstalledModule'} {
                throw "Get-Module doesn't like getting paths without ListAvailable"
            }

            Mock Get-Module -ModuleName $Module -ParameterFilter {$FullyQualifiedName.Name -eq '.\InstalledModule' -and $ListAvailable} {
                return @{ModuleBase = 'C:\Modules\foo\1.2.3'}
            }

            Mock Get-Module -ModuleName $Module {
                return
            }
        }


        InModuleScope $Module {

            It "Works with PSModuleInfo" {
                $TestModulePath = $PSScriptRoot |
                    Join-Path -ChildPath Data |
                    Join-Path -ChildPath ModulePath
                $TestModuleBase = $TestModulePath |
                    Join-Path -ChildPath Dep1

                $TestModule = Import-Module $TestModuleBase -PassThru
                $Output = $TestModule | Resolve-ModulePath
                $Output.Path     | Should -BeExactly $TestModuleBase
                $Output.BasePath | Should -BeExactly $TestModulePath
            }

            It "Finds imported modules by name or ModuleSpec" {

                $Output = "ImportedModule" | Resolve-ModulePath
                $Output.Path     | Should -BeExactly 'C:\Modules\foo\1.2.3'
                $Output.BasePath | Should -BeExactly 'C:\Modules'

                @{ModuleName = "ImportedModule"; ModuleVersion = "1.2.3"} | Resolve-ModulePath
                $Output.Path     | Should -BeExactly 'C:\Modules\foo\1.2.3'
                $Output.BasePath | Should -BeExactly 'C:\Modules'
            }

            It "Does not search for imported modules" {

                "ImportedModule" | Resolve-ModulePath

                Should -Invoke Get-Module -Exactly -Times 0 -ParameterFilter {$FullyQualifiedName.Name -eq 'ImportedModule' -and $ListAvailable}
            }

            It "Finds installed modules by name or ModuleSpec" {

                $Output = "InstalledModule" | Resolve-ModulePath
                $Output.Path     | Should -BeExactly 'C:\Modules\foo\1.2.3'
                $Output.BasePath | Should -BeExactly 'C:\Modules'

                $Output = @{ModuleName = "InstalledModule"; ModuleVersion = "1.2.3"} | Resolve-ModulePath
                $Output.Path     | Should -BeExactly 'C:\Modules\foo\1.2.3'
                $Output.BasePath | Should -BeExactly 'C:\Modules'
            }

            It "Finds installed modules by path" {

                $Output = ".\InstalledModule" | Resolve-ModulePath
                $Output.Path     | Should -BeExactly 'C:\Modules\foo\1.2.3'
                $Output.BasePath | Should -BeExactly 'C:\Modules'
            }

            It "Resolves non-versioned modules" {

                Mock Get-Module -ModuleName $Module -ParameterFilter {$FullyQualifiedName.Name -eq 'ImportedModule' -and -not $ListAvailable} {
                    return @{ModuleBase = 'C:\Modules\foo'}
                }

                $Output = "ImportedModule" | Resolve-ModulePath
                $Output.Path     | Should -BeExactly 'C:\Modules\foo'
                $Output.BasePath | Should -BeExactly 'C:\Modules'
            }

            It "Errors on non-importable modules" {

                {@{ModuleName = 'quux'; GUID = 'deadbeef-dead-beef-f00d-feeddeadbeef'} | Resolve-ModulePath -ErrorAction Stop} | Should -Throw
            }
        }
    }
}
