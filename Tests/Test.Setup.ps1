#requires -Modules @{ModuleName = 'Pester'; ModuleVersion = '5.0.2'}
#requires -PSEdition Desktop

$Module = Import-Module (Split-Path $PSScriptRoot) -Force -PassThru
