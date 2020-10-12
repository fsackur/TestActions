function Resolve-FilePath
{
    <#
        .SYNOPSIS
        Given a path, gets the resolved path and base path.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Path
    )


    process
    {
        $Path |
            Resolve-Path |
            Select-Object Path, BasePath |
            ForEach-Object {

                if (Test-Path $_.Path -PathType Leaf)
                {
                    $_.BasePath = Split-Path $_.Path
                }
                else
                {
                    $_.BasePath = $_.Path
                }


                $_
            }
    }
}
