. (Join-Path $PSScriptRoot Test.Setup.ps1)

Describe "Resolve-FilePath" {

    Context Default {

        BeforeAll {
            Mock Resolve-Path -ModuleName $Module -ParameterFilter {$Path -match 'bar'} {
                return [pscustomobject]@{Path = "C:\foo\$($Path -replace '^\.\\')"}
            }

            Mock Test-Path -ParameterFilter {$PathType -eq 'Leaf'} {
                return $Path -notmatch 'Folder'
            }
        }


        InModuleScope $Module {

            It "Finds files" {

                $Output = 'bar.exe' | Resolve-FilePath
                $Output.Path     | Should -Be 'C:\foo\bar.exe'
                $Output.BasePath | Should -Be 'C:\foo'

                $Output = '.\bar.exe' | Resolve-FilePath
                $Output.Path     | Should -Be 'C:\foo\bar.exe'
                $Output.BasePath | Should -Be 'C:\foo'

                $Output = 'BarFolder' | Resolve-FilePath
                $Output.Path     | Should -Be 'C:\foo\BarFolder'
                $Output.BasePath | Should -Be 'C:\foo\BarFolder'

                $Output = '.\BarFolder' | Resolve-FilePath
                $Output.Path     | Should -Be 'C:\foo\BarFolder'
                $Output.BasePath | Should -Be 'C:\foo\BarFolder'
            }

            It "Errors on non-existent path" {

                {'quux' | Resolve-FilePath -ErrorAction Stop} | Should -Throw
            }
        }
    }
}
