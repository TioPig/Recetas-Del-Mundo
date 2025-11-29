# Remove text notes and SRC comments that reference docs/openapi.json from SVG files
Param()

$root = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent | Split-Path -Parent
$docsPath = Join-Path $root 'docs'

Get-ChildItem -Path $docsPath -Filter *.svg -Recurse | ForEach-Object {
    $path = $_.FullName
    try {
        $content = Get-Content -Path $path -Raw -ErrorAction Stop

        $original = $content

        # Remove any <text>...</text> that contains openapi.json (case-insensitive)
        $content = [regex]::Replace($content, '<text[^>]*?>[^<]*?openapi\.json[^<]*?</text>', '', 'IgnoreCase')

        # Remove any comments like <!--SRC=[...]>-->
        $content = [regex]::Replace($content, '<!--SRC=\[[^\]]*\]-->', '', 'IgnoreCase')

        # Also remove any leftover literal phrase
        $content = $content -replace 'Generado desde `docs/openapi.json`\.', ''

        if ($content -ne $original) {
            Set-Content -Path $path -Value $content -Encoding UTF8
            Write-Output "Cleaned: $path"
        }
    }
    catch {
        Write-Warning "Failed to process $path : $_"
    }
}

Write-Output "Done removing openapi notes from SVGs."
