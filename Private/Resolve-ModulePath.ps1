function Resolve-ModulePath
{
    <#
        .SYNOPSIS
        Find the paths of Powershell modules.

        .DESCRIPTION
        Accepts a search path, a module name, or a ModuleSpecification object. A ModuleSpecification
        can be provided as a hashtable with the following keys being valid:

        - ModuleName
        - ModuleVersion
        - RequiredVersion
        - MaximumVersion
        - GUID

        If a matching module is already imported in the current session, it is returned. Otherwise,
        the normal module resolution order is followed, and the highest matching version is
        returned.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$Module
    )


    begin
    {
        $VersionPattern = '\d+\.\d+\.\d+(\.\d+)?'
        $VersionFolderPattern = [regex]::Escape([IO.Path]::DirectorySeparatorChar) + $VersionPattern + '$'
    }


    process
    {
        $Module | ForEach-Object {

            if ($_ -is [psmoduleinfo])
            {
                return $_
            }


            $ResolvedModule = $null
            $Splat = @{
                FullyQualifiedName = $_
                ErrorAction        = 'SilentlyContinue'
            }


            try
            {
                $ResolvedModule = Get-Module @Splat | Select-Object -First 1
            }
            catch {}

            if ($ResolvedModule)
            {
                Write-Verbose "Found $($ResolvedModule.Name) $($ResolvedModule.Version) from the current session."
                return $ResolvedModule
            }


            $ResolvedModule = Get-Module @Splat -ListAvailable -Verbose:$false |
                Sort-Object Version -Descending |
                Select-Object -First 1

            if ($ResolvedModule)
            {
                Write-Verbose "Found $($ResolvedModule.Name) $($ResolvedModule.Version) at '$($ResolvedModule.ModuleBase)'."
                return $ResolvedModule
            }


            Write-Error "'$_': not a Powershell module, or not in an importable location."


        } | ForEach-Object {

            $BasePath = Split-Path ($_.ModuleBase -replace $VersionFolderPattern)
            [pscustomobject]@{
                Path     = $_.ModuleBase
                BasePath = $BasePath
            }
        }
    }
}
