# Regenera PNG y SVG desde archivos .puml en `docs/` usando plantuml local, jar o Docker.
# Uso: .\generate_from_puml.ps1 [-Width 1200] [-Formats png,svg]
param(
    [int]$Width = 1200,
    [string[]]$Formats = @('png','svg')
)

$root = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent | Split-Path -Parent
$docsPath = Join-Path $root 'docs'

if (-not (Test-Path $docsPath)) {
    Write-Error "No se encontró la carpeta $docsPath"
    exit 1
}

Write-Output "Will generate formats: $($Formats -join ', ') with width $Width px"

# Helper: run plantuml CLI if available
function Run-PlantUML-CLI {
    param($file, $outDir)
    $cmd = "plantuml -tpng -charset UTF-8 -o `"$outDir`" -width $Width `"$file`""
    Write-Output "Trying plantuml command for $file"
    $proc = Start-Process -FilePath "plantuml" -ArgumentList "-tpng","-charset","UTF-8","-o",$outDir,"-width",$Width,$file -NoNewWindow -Wait -PassThru -ErrorAction SilentlyContinue
    return $proc -and $proc.ExitCode -eq 0
}

# Helper: run jar if present at repo root
function Run-PlantUML-Jar {
    param($file, $outDir)
    $jar = Join-Path $root 'plantuml.jar'
    if (-not (Test-Path $jar)) { return $false }
    Write-Output "Using plantuml.jar for $file"
    $args = @('-jar', $jar, '-tpng', '-charset', 'UTF-8', '-o', $outDir, '-width', $Width, $file)
    $proc = Start-Process -FilePath 'java' -ArgumentList $args -NoNewWindow -Wait -PassThru -ErrorAction SilentlyContinue
    return $proc -and $proc.ExitCode -eq 0
}

# Helper: use Docker plantuml image
function Run-PlantUML-Docker {
    param($file, $outDir)
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { return $false }
    Write-Output "Using Docker plantuml image for $file"
    # Mount containing folder and run plantuml inside container. Use absolute Windows path conversion for docker on Windows if needed.
    $abs = (Resolve-Path (Split-Path $file -Parent)).Path
    $baseName = Split-Path $file -Leaf
    $containerCmd = "-tpng -charset UTF-8 -o /work -width $Width /work/$baseName"
    $dockerArgs = @('run','--rm','-v', ($abs + ':/work'), 'plantuml/plantuml') + $containerCmd.Split(' ')
    $proc = Start-Process -FilePath 'docker' -ArgumentList $dockerArgs -NoNewWindow -Wait -PassThru -ErrorAction SilentlyContinue
    return $proc -and $proc.ExitCode -eq 0
}

# Iterate .puml files
$pumls = Get-ChildItem -Path $docsPath -Filter *.puml -Recurse
if ($pumls.Count -eq 0) { Write-Output "No .puml files found under $docsPath"; exit 0 }

foreach ($p in $pumls) {
    $file = $p.FullName
    $dir = Split-Path $file -Parent
    Write-Output "Processing: $file"

    $generated = $false

    # Try local plantuml command
    if (Get-Command plantuml -ErrorAction SilentlyContinue) {
        foreach ($fmt in $Formats) {
            Write-Output "Generating $fmt via plantuml command: $file"
            # plantuml tool handles format selection; we'll call it per-format
            $args = @('-t' + $fmt, '-charset', 'UTF-8', '-o', $dir, '-width', $Width, $file)
            $proc = Start-Process -FilePath 'plantuml' -ArgumentList $args -NoNewWindow -Wait -PassThru -ErrorAction SilentlyContinue
            if ($proc -and $proc.ExitCode -eq 0) { $generated = $true }
            else { Write-Warning "plantuml command failed for $file format $fmt" }
        }
    }
    elseif (Test-Path (Join-Path $root 'plantuml.jar')) {
        foreach ($fmt in $Formats) {
            Write-Output "Generating $fmt via plantuml.jar: $file"
            $args = @('-jar', (Join-Path $root 'plantuml.jar'), '-t' + $fmt, '-charset', 'UTF-8', '-o', $dir, '-width', $Width, $file)
            $proc = Start-Process -FilePath 'java' -ArgumentList $args -NoNewWindow -Wait -PassThru -ErrorAction SilentlyContinue
            if ($proc -and $proc.ExitCode -eq 0) { $generated = $true }
            else { Write-Warning "plantuml.jar failed for $file format $fmt" }
        }
    }
    elseif (Get-Command docker -ErrorAction SilentlyContinue) {
        foreach ($fmt in $Formats) {
            Write-Output "Generating $fmt via Docker for $file"
            $abs = (Resolve-Path $file).Path
            $pdir = Split-Path $abs -Parent
            $base = Split-Path $abs -Leaf
            # docker run -v $pdir:/work plantuml/plantuml -t$fmt -width $Width /work/$base
            $args = @('run','--rm','-v', ($pdir + ':/work'), 'plantuml/plantuml', ("-t$fmt"), ("-width"), ("$Width"), ("/work/$base"))
            $proc = Start-Process -FilePath 'docker' -ArgumentList $args -NoNewWindow -Wait -PassThru -ErrorAction SilentlyContinue
            if ($proc -and $proc.ExitCode -eq 0) { $generated = $true }
            else { Write-Warning "docker plantuml failed for $file format $fmt" }
        }
    }
    else {
        Write-Warning "No plantuml CLI/jar/docker available to generate $file. Install plantuml or docker."
    }

    if ($generated) { Write-Output "Generated outputs for $file" }
}

Write-Output "Done generating diagrams from .puml"
