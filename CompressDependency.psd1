@{
    Description       = 'Like a self-extracting zip, but in a .ps1 script!'
    ModuleToProcess   = 'CompressDependency.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = 'ecdcdd30-fc42-4306-8b6c-f657e680acdc'

    Author            = 'Freddie Sackur'
    CompanyName       = 'Dusty Fox'
    Copyright         = '(c) Freddie Sackur. All rights reserved.'
    PowerShellVersion = '5.0'

    RequiredModules   = @()

    FunctionsToExport = @(
        'Compress-Dependency'
    )

    PrivateData       = @{
        PSData = @{
            ProjectUri    = 'https://raw.githubusercontent.com/fsackur/CompressDependency'
            LicenseUri    = 'https://raw.githubusercontent.com/fsackur/CompressDependency/main/LICENSE'
            ReleaseNotes  = 'https://raw.githubusercontent.com/fsackur/CompressDependency/main/CHANGELOG.md'

            Tags          = @(
                'Dependency',
                'Module'
            )
        }
    }
}
