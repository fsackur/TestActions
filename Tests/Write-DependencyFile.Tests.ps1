. (Join-Path $PSScriptRoot Test.Setup.ps1)


Describe Write-DependencyFile {

    $Script:TestDrive = $env:TEMP |
        Join-Path -ChildPath ($Module.Name + '.Test') |
        Join-Path -ChildPath (Get-Random -Minimum 10000000 -Maximum 99999999)

    $Script:ModulePath = Join-Path $TestDrive ModulePath
    $null = New-Item $ModulePath -ItemType Directory

    $Script:TestDataFolder = Join-Path $PSScriptRoot Data
    $TestDataFile = $TestDataFolder |
        Join-Path -ChildPath OutputPath |
        Join-Path -ChildPath Compressed.ps1

    $Script:TestData = . $TestDataFile

    Push-Location $TestDrive



    Context Default {

        InModuleScope $Module {

            It "Defaults to current working directory" {

                $TestData[-1] | Write-DependencyFile
                Test-Path $TestData[-1].Path | Should -Be $true
                Remove-Item (Split-Path $TestData[-1].Path) -Recurse -Force
            }

            It "Respects absolute paths" {

                $Path = Join-Path $PWD foo
                Write-DependencyFile -Bytes $TestData[1].Bytes -Path $Path
                Test-Path $Path | Should -Be $true
                Remove-Item $Path
            }


            $TestData | Write-DependencyFile -OutputFolder ModulePath

            $Script:ExpectedFiles = Get-ChildItem (Join-Path $TestDataFolder ModulePath) -Recurse
            $Script:WrittenFiles  = Get-ChildItem $ModulePath -Recurse

            It "Copies all files" {

                Compare-Object $ExpectedFiles.Name $WrittenFiles.Name | Should -BeNullOrEmpty
            }

            It "Copies correctly" {

                $ExpectedHashes = $ExpectedFiles | Get-FileHash | Select-Object -ExpandProperty Hash
                $WrittenHashes  = $WrittenFiles  | Get-FileHash | Select-Object -ExpandProperty Hash
                Compare-Object $ExpectedHashes $WrittenHashes | Should -BeNullOrEmpty
            }

            It "Imports module" {

                Join-Path $ModulePath Dep1 | Import-Module -PassThru | Should -Not -BeNullOrEmpty
            }

            It "Runs binary" {

                $BinaryPath = Join-Path $ModulePath 'curl.exe'
                (& $BinaryPath --version) -match 'curl 7.55.1' | Should -Not -BeNullOrEmpty
            }
        }
    }


    AfterAll {
        Pop-Location
        Remove-Item $Script:TestDrive -Recurse -Force
    }
}
