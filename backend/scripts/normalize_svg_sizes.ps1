# Normaliza el tamaño mostrado de SVGs bajo docs/ manteniendo la proporción del viewBox.
# Para cada SVG: toma viewBox width (o atributo width), resta 200px y ajusta height proporcionalmente.
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

        # Extract opening <svg ...> tag
        $m = [regex]::Match($content, '<svg[^>]*>', 'IgnoreCase')
        if (-not $m.Success) { Write-Warning "No opening <svg> tag in $path"; return }
        $svgTag = $m.Value

        # Try to get viewBox: expected format 'minX minY width height'
        $vbMatch = [regex]::Match($svgTag, 'viewBox="([^"]+)"', 'IgnoreCase')
        $origW = $null; $origH = $null
        if ($vbMatch.Success) {
            $parts = $vbMatch.Groups[1].Value -split '\s+' | Where-Object { $_ -ne '' }
            if ($parts.Count -ge 4) {
                $origW = [double]$parts[2]
                $origH = [double]$parts[3]
            }
        }

        # Fallback: parse width and height attributes from tag (numbers only)
        if (-not $origW) {
            $wa = [regex]::Match($svgTag, 'width="([0-9]+)px"', 'IgnoreCase')
            $ha = [regex]::Match($svgTag, 'height="([0-9]+)px"', 'IgnoreCase')
            if ($wa.Success -and $ha.Success) {
                $origW = [double]$wa.Groups[1].Value
                $origH = [double]$ha.Groups[1].Value
            }
        }

        if (-not $origW -or -not $origH) {
            Write-Warning "No se pudo determinar proporción (viewBox o width/height) en $path; se omite"
            return
        }

        # Compute new width and height
        $newW = [math]::Max(1, [math]::Round($origW - 200))
        $ratio = $origH / $origW
        $newH = [math]::Max(1, [math]::Round($newW * $ratio))

        # Update width="NNNpx" and height="NNNpx"
        if ([regex]::IsMatch($svgTag, '(?i)width="[0-9]+px"')) {
            $svgTag = [regex]::Replace($svgTag, '(?i)width="[0-9]+px"', "width=`"$($newW)px`"")
        } else {
            $svgTag = $svgTag -replace '<svg','<svg width="' + $newW + 'px"'
        }

        if ([regex]::IsMatch($svgTag, '(?i)height="[0-9]+px"')) {
            $svgTag = [regex]::Replace($svgTag, '(?i)height="[0-9]+px"', "height=`"$($newH)px`"")
        } else {
            $svgTag = $svgTag -replace '<svg','<svg height="' + $newH + 'px"'
        }

        # Update style="...width:NNNpx;...height:NNNpx;..." (case-insensitive via (?i))
        if ([regex]::IsMatch($svgTag, '(?i)style="[^"]*width:\s*[0-9]+px')) {
            $svgTag = [regex]::Replace($svgTag, '(?i)width:\s*[0-9]+px', 'width:' + $newW + 'px')
        } elseif ([regex]::IsMatch($svgTag, '(?i)style="[^"]*"')) {
            # append width to style content
            $svgTag = [regex]::Replace($svgTag, '(?i)(style=")([^"]*)(")', '$1$2width:' + $newW + 'px;$3')
        }

        if ([regex]::IsMatch($svgTag, '(?i)style="[^"]*height:\s*[0-9]+px')) {
            $svgTag = [regex]::Replace($svgTag, '(?i)height:\s*[0-9]+px', 'height:' + $newH + 'px')
        } elseif ([regex]::IsMatch($svgTag, '(?i)style="[^"]*"')) {
            $svgTag = [regex]::Replace($svgTag, '(?i)(style=")([^"]*)(")', '$1$2height:' + $newH + 'px;$3')
        }

        # Replace the opening tag in content
        $content = $content.Substring(0, $m.Index) + $svgTag + $content.Substring($m.Index + $m.Length)
        Set-Content -Path $path -Value $content -Encoding UTF8
        Write-Output "Normalized: $path -> ${newW}px x ${newH}px"
    }
    catch {
        Write-Warning "Failed to process $path : $_"
    }
}

Write-Output "Done normalizing SVG sizes."
