<#
  scripts/install_and_run_stripe.ps1

  Descarga la última release de stripe-cli para Windows desde GitHub,
  extrae stripe.exe en ./scripts/stripe-bin y ejecuta el script
  add_stripe_webhook_secret.ps1 para capturar el whsec_... y actualizar .env.

  Uso: desde la raíz del repo en PowerShell
    pwsh .\scripts\install_and_run_stripe.ps1
#>

$ErrorActionPreference = 'Stop'
Write-Host "Buscando release más reciente de stripe-cli en GitHub..."
$api = 'https://api.github.com/repos/stripe/stripe-cli/releases/latest'
$rel = Invoke-RestMethod -Uri $api -Headers @{ 'User-Agent' = 'powershell' }

# Buscar asset apropiado para Windows (preferir zips/exes/msi)
$asset = $rel.assets | Where-Object { $_.name -match '\.zip$' -or $_.name -match '\.msi$' -or $_.name -match '\.exe$' } | Select-Object -First 1
if (-not $asset) {
    # fallback: try anything that mentions windows or win
    $asset = $rel.assets | Where-Object { $_.name -match 'windows' -or $_.name -match 'win' } | Select-Object -First 1
}
if (-not $asset) {
    Write-Host "No se encontró asset para Windows en la release. Lista de assets:" -ForegroundColor Yellow
    $rel.assets | ForEach-Object { Write-Host $_.name }
    exit 2
}

$url = $asset.browser_download_url
Write-Host "Descargando $($asset.name) desde $url ..."
$out = Join-Path -Path (Get-Location) -ChildPath 'stripe_cli.zip'
Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing -ErrorAction Stop

$binDir = Join-Path -Path (Get-Location) -ChildPath 'scripts\stripe-bin'
if (-not (Test-Path $binDir)) { New-Item -ItemType Directory -Path $binDir | Out-Null }

Write-Host "Extrayendo $out a $binDir ..."
Expand-Archive -LiteralPath $out -DestinationPath $binDir -Force
Remove-Item $out -Force

Write-Host "Buscando stripe.exe en $binDir ..."
$possible = Get-ChildItem -Path $binDir -Recurse -Filter 'stripe.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $possible) {
    Write-Host 'No se encontró stripe.exe dentro del zip extraído.' -ForegroundColor Red
    exit 3
}

$dir = $possible.DirectoryName
Write-Host "Stripe CLI encontrado en: $dir"

# Añadir temporalmente al PATH de la sesión
$env:Path = $dir + ';' + $env:Path

Write-Host "Versión de stripe:";
& "$dir\stripe.exe" version

Write-Host "Ejecutando script add_stripe_webhook_secret.ps1..."
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\add_stripe_webhook_secret.ps1
