function Write-DependencyFile
{
    <#
        .SYNOPSIS
        Write file content.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Bytes,

        [Parameter()]
        [string]$OutputFolder = $PWD.Path
    )

    begin
    {
        if (-not [IO.Path]::IsPathRooted($OutputFolder))
        {
            $OutputFolder = Join-Path $PWD $OutputFolder
        }
    }


    process
    {
        if (-not [IO.Path]::IsPathRooted($Path))
        {
            $Path = Join-Path $OutputFolder $Path
        }


        $Container = Split-Path $Path
        if (-not (Test-Path $Container -PathType Container))
        {
            $null = New-Item $Container -ItemType Directory -Force
        }

        $RawBytes = [Convert]::FromBase64String($Bytes)
        [IO.File]::WriteAllBytes($Path, $RawBytes)
    }
}
