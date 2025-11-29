# Make style width and width attribute consistent: use the current `width="NNNpx"` value
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

        # Find opening svg tag
        $m = [regex]::Match($content, '<svg[^>]*>', 'IgnoreCase')
        if (-not $m.Success) { Write-Warning "No opening <svg> tag in $path"; return }
        $svgTag = $m.Value

        # Get width="NNNpx" from the tag
        $wa = [regex]::Match($svgTag, 'width="(\d+)px"', 'IgnoreCase')
        if ($wa.Success) {
            $widthVal = [int]$wa.Groups[1].Value
            # Replace style width:NNNpx within opening tag
            if ([regex]::IsMatch($svgTag, 'style="[^"]*width:\s*\d+px', 'IgnoreCase')) {
                $newTag = [regex]::Replace($svgTag, '(style="[^"]*?width:\s*)(\d+)px', { param($mm) return $mm.Groups[1].Value + $widthVal + 'px' }, 'IgnoreCase')
            }
            else {
                # If style exists but no width, try to append width
                if ([regex]::IsMatch($svgTag, 'style="[^"]*"', 'IgnoreCase')) {
                    $newTag = [regex]::Replace($svgTag, '(style=")([^"]*)(")', { param($mm) return $mm.Groups[1].Value + $mm.Groups[2].Value + 'width:' + $widthVal + 'px;' + $mm.Groups[3].Value }, 'IgnoreCase')
                }
                else { $newTag = $svgTag }
            }

            # Ensure width attribute is present and set
            if (-not [regex]::IsMatch($newTag, 'width="\d+px"')) {
                $newTag = $newTag -replace '<svg','<svg'
                # insert width before closing of tag
                $newTag = $newTag -replace '(^<svg)([^>]*)', { param($mm) return $mm.Groups[1].Value + $mm.Groups[2].Value + " width=\"${widthVal}px\"" }
            }

            # Replace the opening tag in content
            $content = $content.Substring(0, $m.Index) + $newTag + $content.Substring($m.Index + $m.Length)
            Set-Content -Path $path -Value $content -Encoding UTF8
            Write-Output "Fixed: $path (width set to ${widthVal}px)"
        }
        else {
            Write-Warning "No width attribute found in $path; skipping"
        }
    }
    catch {
        Write-Warning "Failed to process $path : $_"
    }
}

Write-Output "Done fixing SVG tags."
