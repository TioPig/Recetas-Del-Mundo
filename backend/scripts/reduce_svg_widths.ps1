# Reduce 200px from horizontal width in all SVG files under docs/
Param()

$root = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent | Split-Path -Parent
$docsPath = Join-Path $root 'docs'

if (-not (Test-Path $docsPath)) {
    Write-Error "No se encontró la carpeta $docsPath"
    exit 1
}

Get-ChildItem -Path $docsPath -Filter *.svg -Recurse | ForEach-Object {
    $path = $_.FullName
    try {
        $content = Get-Content -Path $path -Raw -ErrorAction Stop

        # Replace style width:NNNpx (e.g. style="width:1400px;height:600px;...")
        $content = [regex]::Replace($content, '(style="[^"]*?width:\s*)(\d+)px', {
            param($m)
            $orig = [int]$m.Groups[2].Value
            $new = [math]::Max(0, $orig - 200)
            return $m.Groups[1].Value + $new + 'px'
        }, 'IgnoreCase')

        # Replace width="NNNpx"
        $content = [regex]::Replace($content, '(\bwidth=")([0-9]+)px("?)', {
            param($m)
            $orig = [int]$m.Groups[2].Value
            $new = [math]::Max(0, $orig - 200)
            return $m.Groups[1].Value + $new + 'px' + $m.Groups[3].Value
        }, 'IgnoreCase')

        # Also handle standalone width:NNNpx; without style= (just in case)
        $content = [regex]::Replace($content, '(width:\s*)(\d+)px', {
            param($m)
            $orig = [int]$m.Groups[2].Value
            $new = [math]::Max(0, $orig - 200)
            return $m.Groups[1].Value + $new + 'px'
        }, 'IgnoreCase')

        Set-Content -Path $path -Value $content -Encoding UTF8
        Write-Output "Updated: $path"
    }
    catch {
        Write-Warning "Failed to update $path : $_"
    }
}

Write-Output "Done."
