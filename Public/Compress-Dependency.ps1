function Compress-Dependency
{
    <#
        .SYNOPSIS
        Serialises dependencies as Base64, so they can be copied in a single file.

        .DESCRIPTION
        Copying dependencies to remote machines can be a problem. This command makes it easy to copy
        dependencies with script data.

        Think of this as a self-extracting zip, encoded as Powershell script. Run this command on
        your own machine with a recent version of Powershell; create a self-extracting script file
        that can be used with legacy script execution systems, and run your code on older machines.

        Works with Powershell script and binary files.

        Files for dependencies are read as bytes and encoded as Base64 strings, along with their
        paths.
    #>
    [CmdletBinding(DefaultParameterSetName = 'AsPSObject')]
    param
    (
        [Parameter()]
        [object[]]$RequiredModules,

        [Parameter()]
        [string[]]$RequiredFiles
    )


    $Dependencies = [Collections.ArrayList]::new()

    $RequiredModules |
        Resolve-ModulePath |
        ForEach-Object {$null = $Dependencies.Add($_)}

    $RequiredFiles |
        Resolve-FilePath |
        ForEach-Object {$null = $Dependencies.Add($_)}

    $Dependencies |
        ForEach-Object {
            Get-ChildItem $_.Path -Recurse |
                Select-Object -ExpandProperty FullName |
                Read-DependencyFile -BasePath $_.BasePath
        }
}
