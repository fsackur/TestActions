. (Join-Path $PSScriptRoot Test.Setup.ps1)


Describe Compress-Dependency {



    InModuleScope $Module {

        BeforeAll {

            Mock Resolve-ModulePath {
                [pscustomobject]@{
                    Path     = 'C:\Modules\Foo\1.2.3'
                    BasePath = 'C:\Modules'
                }
            }

            Mock Resolve-FilePath {
                [pscustomobject]@{
                    Path     = 'C:\Binaries\bar.exe'
                    BasePath = 'C:\Binaries'
                }
            }



            Mock Get-ChildItem -ParameterFilter { $Path -match 'Modules' -and $Recurse } {
                [pscustomobject]@{FullName = Join-Path $Path 'Foo.psd1' }
                [pscustomobject]@{FullName = Join-Path $Path 'Foo.psm1' }
            }

            Mock Get-ChildItem -ParameterFilter { $Path -match 'Binaries' } {
                [pscustomobject]@{FullName = $Path }
            }

            Mock Get-ChildItem { throw "Wrong input!" }



            Mock Read-DependencyFile -ParameterFilter { $Path -match 'Modules' } {
                [pscustomobject]@{
                    Path  = $Path -replace 'C:\\Modules\\'
                    Bytes = 'ZGVhZGJlZWY='
                }
            }

            Mock Read-DependencyFile -ParameterFilter { $Path -match 'Binaries' } {
                [pscustomobject]@{
                    Path  = 'bar.exe'
                    Bytes = 'ZGVhZGJlZWY='
                }
            }

            Mock Read-DependencyFile { throw "Wrong input!" }
        }



        Context AsPSObject {

            It "Works" {

                $Output = Compress-Dependency -RequiredModules 'Foo' -RequiredFiles 'bar.exe'

                $Output.Path  | Should -BeExactly 'Foo\1.2.3\Foo.psd1', 'Foo\1.2.3\Foo.psm1', 'bar.exe'
                $Output.Bytes | Should -BeExactly 'ZGVhZGJlZWY=', 'ZGVhZGJlZWY=', 'ZGVhZGJlZWY='
            }
        }
    }
}
