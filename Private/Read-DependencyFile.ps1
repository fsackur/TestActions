function Read-DependencyFile
{
    <#
        .SYNOPSIS
        Get metadata and content of a file.

        .PARAMETER BasePath
        Provide a path within which to resolve relative paths. Has no effect on absolute paths.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Path,

        [Parameter()]
        [string]$BasePath = $PWD.Path
    )

    begin
    {
        $BasePath        = Resolve-Path $BasePath -ErrorAction Stop
        $RelativePattern = [regex]::Escape($BasePath) + [regex]::Escape([IO.Path]::DirectorySeparatorChar)
    }


    process
    {
        if (-not [IO.Path]::IsPathRooted($Path))
        {
            $FullPath = Join-Path $BasePath $Path
        }
        else
        {
            $FullPath = $Path
        }

        $Resolved = Resolve-Path $FullPath
        if (-not $?) {return}
        $FullPath = $Resolved.Path


        if (Test-Path $FullPath -PathType Container)
        {
            Write-Verbose "Skipping '$Fullpath' because it is a directory."
            return
        }


        $Path = $FullPath -replace $RelativePattern


        $Output = 1 | Select-Object (
            'Path',
            'Bytes'
        )

        $Bytes = [IO.File]::ReadAllBytes($FullPath)

        $Output.Path  = $Path
        $Output.Bytes = [Convert]::ToBase64String($Bytes)


        $Output
    }
}
