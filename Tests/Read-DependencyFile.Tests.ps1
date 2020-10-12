. (Join-Path $PSScriptRoot Test.Setup.ps1)


Describe Read-DependencyFile {

    $Script:TestDrive = $env:TEMP |
        Join-Path -ChildPath ($Module.Name + '.Test') |
        Join-Path -ChildPath (Get-Random -Minimum 10000000 -Maximum 99999999)

    $Script:ModulePath = Join-Path $TestDrive ModulePath
    $null = New-Item $ModulePath -ItemType Directory

    $PSScriptRoot |
        Join-Path -ChildPath 'Data' |
        Join-Path -ChildPath 'ModulePath' |
        Get-ChildItem |
        Copy-Item -Destination $ModulePath -Recurse

    Push-Location $TestDrive


    Context Default {

        InModuleScope $Module {

            $Script:TestPaths = (
                'ModulePath\Dep1\Dep1.psd1',
                '.\ModulePath\Dep1\Dep1.psd1',
                (Join-Path $PWD 'ModulePath\Dep1\Dep1.psd1')
            )


            It "Resolves paths nicely" {

                (
                    'ModulePath\Dep1\Dep1.psd1',
                    '.\ModulePath\Dep1\Dep1.psd1',
                    (Join-Path $PWD 'ModulePath\Dep1\Dep1.psd1')
                ) |
                    Read-DependencyFile |
                    Select-Object -ExpandProperty Path -Unique |
                    Should -BeExactly "ModulePath\Dep1\Dep1.psd1"
            }

            It "Accepts a relative base path" {

                (
                    'Dep1\Dep1.psd1',
                    '.\Dep1\Dep1.psd1',
                    (Join-Path $PWD 'ModulePath\Dep1\Dep1.psd1')
                ) |
                    Read-DependencyFile -BasePath ModulePath |
                    Select-Object -ExpandProperty Path -Unique |
                    Should -BeExactly "Dep1\Dep1.psd1"
            }

            It "Accepts an absolute base path" {

                (
                    'Dep1\Dep1.psd1',
                    '.\Dep1\Dep1.psd1',
                    (Join-Path $PWD 'ModulePath\Dep1\Dep1.psd1')
                ) |
                    Read-DependencyFile -BasePath (Resolve-Path ModulePath).Path |
                    Select-Object -ExpandProperty Path -Unique |
                    Should -BeExactly "Dep1\Dep1.psd1"
            }

            It "Reads .psd1 bytes" {

                $Output = 'ModulePath\Dep1\Dep1.psd1' | Read-DependencyFile
                $Bytes = $Output.Bytes
                $Bytes.Length | Should -BeExactly 240
                $Bytes.Substring(0, 10) | Should -BeExactly 'QHsNCiAgIC'
                $Bytes.Substring($Bytes.Length - 10) | Should -BeExactly 'AwJw0KfQ0K'
            }

            It "Reads .exe bytes" {

                $Output = 'curl.exe' | Read-DependencyFile -BasePath ModulePath
                $Bytes = $Output.Bytes
                $Bytes.Length | Should -BeExactly 561836
                $Bytes.Substring(0, 10) | Should -BeExactly 'TVqQAAMAAA'
                $Bytes.Substring($Bytes.Length - 10) | Should -BeExactly 'AAAAAAAAA='
            }

            It "Skips directories" {

                $Output = 'ModulePath' | Read-DependencyFile
                $Output | Should -BeNullOrEmpty
            }

            $Script:FooErrorMessage = "Cannot find path '$PWD\foo' because it does not exist."

            It "Errors on non-existent relative path" {

                {'foo' | Read-DependencyFile -ErrorAction Stop} | Should -Throw $FooErrorMessage
            }

            It "Errors on non-existent absolute path" {

                {"$PWD\foo" | Read-DependencyFile -ErrorAction Stop} | Should -Throw $FooErrorMessage
            }

            It "Errors on non-existent relative base path" {

                {'ModulePath\Dep1\Dep1.psd1' | Read-DependencyFile -BasePath 'foo' -ErrorAction Stop} | Should -Throw $FooErrorMessage
            }

            It "Errors on non-existent absolute base path" {

                {'ModulePath\Dep1\Dep1.psd1' | Read-DependencyFile -BasePath "$PWD\foo" -ErrorAction Stop} | Should -Throw $FooErrorMessage
            }
        }
    }


    AfterAll {
        Pop-Location
        Remove-Item $Script:TestDrive -Recurse -Force
    }
}
