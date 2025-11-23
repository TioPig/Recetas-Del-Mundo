<# DEPRECATED: original script preserved in scripts/deprecated/e2e_donacion_test.ps1 #>
Write-Host 'This file has been deprecated and the original preserved in scripts/deprecated/e2e_donacion_test.ps1'

param(
        [double]
        $Amount = 100,
        [switch]
        $SkipStart
)

Set-StrictMode -Version Latest
function CleanupAndExit([int]$code=1) {
    if (Get-Variable -Name pid -Scope Script -ErrorAction SilentlyContinue) {
        if ($pid) { Try { Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue } Catch { } }
    }
    if (Get-Variable -Name batPath -Scope Script -ErrorAction SilentlyContinue) {
        if ($batPath -and (Test-Path $batPath)) { Remove-Item $batPath -ErrorAction SilentlyContinue }
    }
    exit $code
}
Try {
    $repoRoot = Resolve-Path -Path "$PSScriptRoot\.." | Select-Object -ExpandProperty Path
} Catch {
    $repoRoot = (Get-Location).Path
}
Set-Location $repoRoot

Write-Host "[e2e] Repo root: $repoRoot"

$envFile = Join-Path $repoRoot '.env'
if (-not (Test-Path $envFile)) { Write-Error ".env no encontrado en $envFile"; exit 1 }

# El JAR sólo es necesario si no usamos -SkipStart
$jarRel = 'Springboot\target\api-recetas-0.0.1-SNAPSHOT.jar'
$jarFull = $null

# Leer .env y crear batch temporal para exportar variables al proceso Java (PowerShell 5.1 no soporta Start-Process -Environment)
$envLines = Get-Content $envFile | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') }
$sets = @()
<#
.SYNOPSIS
    Prueba E2E para donaciones: crea una sesión de donación (por defecto 100 USD), verifica filas en Postgres y envía webhook simulado.

.NOTES
    - Diseñado para ejecutarse en Windows PowerShell 5.1 desde la raíz del repo.
    - Requiere que el JAR `Springboot/target/api-recetas-0.0.1-SNAPSHOT.jar` exista (compilar con Maven si no).
    - Usa el archivo `.env` en la raíz para pasar variables al proceso Java (se genera un .bat temporal).
    - Ajusta variables `POSTGRES_CONTAINER`, `POSTGRES_DB` si tu entorno difiere.

USAGE
    powershell -ExecutionPolicy Bypass -File .\scripts\e2e_donacion_test.ps1 -Amount 100
#>

param(
        [double]
        $Amount = 100,
        [switch]
        $SkipStart,
        [int]
        $UserId = 0
)

Set-StrictMode -Version Latest
function CleanupAndExit([int]$code=1) {
    if (Get-Variable -Name pid -Scope Script -ErrorAction SilentlyContinue) {
        if ($pid) { Try { Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue } Catch { } }
    }
    if (Get-Variable -Name batPath -Scope Script -ErrorAction SilentlyContinue) {
        if ($batPath -and (Test-Path $batPath)) { Remove-Item $batPath -ErrorAction SilentlyContinue }
    }
    exit $code
}
Try {
    $repoRoot = Resolve-Path -Path "$PSScriptRoot\.." | Select-Object -ExpandProperty Path
} Catch {
    $repoRoot = (Get-Location).Path
}
Set-Location $repoRoot

Write-Host "[e2e] Repo root: $repoRoot"

$envFile = Join-Path $repoRoot '.env'
if (-not (Test-Path $envFile)) { Write-Error ".env no encontrado en $envFile"; exit 1 }

# El JAR sólo es necesario si no usamos -SkipStart
$jarRel = 'Springboot\target\api-recetas-0.0.1-SNAPSHOT.jar'
$jarFull = $null

# Leer .env y crear batch temporal para exportar variables al proceso Java (PowerShell 5.1 no soporta Start-Process -Environment)
$envLines = Get-Content $envFile | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') }
$sets = @()
<#
.SYNOPSIS
    Prueba E2E para donaciones: crea una sesión de donación (por defecto 100 USD), verifica filas en Postgres y envía webhook simulado.

.NOTES
    - Diseñado para ejecutarse en Windows PowerShell 5.1 desde la raíz del repo.
    - Requiere que el JAR `Springboot/target/api-recetas-0.0.1-SNAPSHOT.jar` exista (compilar con Maven si no).
    - Usa el archivo `.env` en la raíz para pasar variables al proceso Java (se genera un .bat temporal).
    - Ajusta variables `POSTGRES_CONTAINER`, `POSTGRES_DB` si tu entorno difiere.

USAGE
    powershell -ExecutionPolicy Bypass -File .\scripts\e2e_donacion_test.ps1 -Amount 100
#>

param(
    [double]
    $Amount = 100,
    [switch]
    $SkipStart,
    [int]
    $UserId = 0
)

Set-StrictMode -Version Latest
function CleanupAndExit([int]$code=1) {
    if (Get-Variable -Name pid -Scope Script -ErrorAction SilentlyContinue) {
        if ($pid) { Try { Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue } Catch { } }
    }
    if (Get-Variable -Name batPath -Scope Script -ErrorAction SilentlyContinue) {
        if ($batPath -and (Test-Path $batPath)) { Remove-Item $batPath -ErrorAction SilentlyContinue }
    }
    exit $code
}

Try { $repoRoot = Resolve-Path -Path "$PSScriptRoot\.." | Select-Object -ExpandProperty Path } Catch { $repoRoot = (Get-Location).Path }
Set-Location $repoRoot
Write-Host "[e2e] Repo root: $repoRoot"

$envFile = Join-Path $repoRoot '.env'
if (-not (Test-Path $envFile)) { Write-Error ".env no encontrado en $envFile"; exit 1 }

# El JAR sólo es necesario si no usamos -SkipStart
$jarRel = 'Springboot\target\api-recetas-0.0.1-SNAPSHOT.jar'
$jarFull = $null

# Leer .env y crear batch temporal para exportar variables al proceso Java
$envLines = Get-Content $envFile | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') }
$sets = @()
foreach ($ln in $envLines) {
    if ($ln -match '^(.*?)=(.*)$') {
        $k = $matches[1].Trim(); $v = $matches[2].Trim()
        if ($v.StartsWith("'") -and $v.EndsWith("'")) { $v = $v.Substring(1,$v.Length-2) }
        if ($v.StartsWith('"') -and $v.EndsWith('"')) { $v = $v.Substring(1,$v.Length-2) }
        $sets += 'set "' + $k + '=' + $v + '"'
    }
}

if (-not $SkipStart) {
    $jarFull = Join-Path $repoRoot $jarRel
    if (-not (Test-Path $jarFull)) { Write-Error "JAR no encontrado: $jarFull. Ejecuta 'mvn -DskipTests package' en Springboot."; CleanupAndExit 1 }
    $batPath = Join-Path $env:TEMP "run_recetas_env_$(Get-Random).bat"
    $bat = @(); $bat += "@echo off"; $bat += "setlocal"; $bat += $sets; $bat += "echo Starting java process with environment from .env..."
    $bat += 'start "recetas_app" java -jar "' + $jarFull + '"'; $bat += "exit /b 0"
    Set-Content -Path $batPath -Value $bat -Encoding ASCII
    Write-Host "[e2e] Batch temporal creado: $batPath"
    cmd.exe /c $batPath; Start-Sleep -Seconds 3
    $javaProc = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -and $_.CommandLine -like "*api-recetas-0.0.1-SNAPSHOT.jar*" } | Select-Object -First 1
    if ($null -eq $javaProc) { Write-Error "No se encontró proceso java con el jar"; Remove-Item $batPath -ErrorAction SilentlyContinue; exit 1 }
    $pid = $javaProc.ProcessId; Write-Host "[e2e] Proceso Java arrancado PID=$pid"
} else { Write-Host "[e2e] SkipStart activado: usando backend Docker en localhost:8081" }

# Esperar backend
$ready = $false
for ($i=0; $i -lt 60; $i++) { try { $r = Invoke-WebRequest -UseBasicParsing -Uri 'http://localhost:8081/recetas/trending' -TimeoutSec 3; if ($r.StatusCode -eq 200) { $ready = $true; break } } catch { Start-Sleep -Seconds 1 } }
if (-not $ready) { Write-Error "Backend no respondió en 60s"; CleanupAndExit 1 }
Write-Host "[e2e] Backend UP"

# JWT
$envHash = @{}; Get-Content $envFile | ForEach-Object { $ln = $_.Trim(); if ($ln -and -not $ln.StartsWith('#')) { if ($ln -match '^(.*?)=(.*)$') { $envHash[$matches[1].Trim()] = $matches[2].Trim().Trim("'\"") } } }
if (-not $envHash.ContainsKey('JWT_SECRET')) { Write-Error "JWT_SECRET no encontrado en .env"; CleanupAndExit 1 }
$secret = $envHash['JWT_SECRET']
$epoch = [int](([DateTime]::UtcNow - [DateTime]'1970-01-01').TotalSeconds); $exp = $epoch + 3600
$header = '{"alg":"HS256","typ":"JWT"}'; $uid = if ($UserId -gt 0) { $UserId } else { 1 }
$payload = '{"id_usr":' + $uid.ToString() + ',"sub":"test@example.com","exp":' + $exp.ToString() + '}'
function b64url([string]$s) { $b = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($s)); $b = $b.TrimEnd('='); $b = $b.Replace('+','-').Replace('/','_'); return $b }
$h = b64url $header; $p = b64url $payload
$hmac = New-Object System.Security.Cryptography.HMACSHA256([System.Text.Encoding]::UTF8.GetBytes($secret))
$sigBytes = $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes("$h.$p"))
$sig = [Convert]::ToBase64String($sigBytes).TrimEnd('=') -replace '\+','-' -replace '/','_'
$token = "$h.$p.$sig"; Write-Host "[e2e] JWT generado (id_usr=$uid)"

# Crear session
$amountCents = [int]([math]::Round($Amount * 100)); $body = @{ amount = $amountCents } | ConvertTo-Json
Write-Host "[e2e] Creando session de donación: $Amount USD ($amountCents cents)"
try { $resp = Invoke-RestMethod -Method Post -Uri 'http://localhost:8081/donaciones/create-session' -Headers @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' } -Body $body -TimeoutSec 30 } catch { Write-Error "Fallo create-session: $_"; if (-not $SkipStart) { CleanupAndExit 1 } else { CleanupAndExit 1 } }
Write-Host "[e2e] Respuesta create-session:"; $resp | ConvertTo-Json -Depth 6 | Write-Host

# Extraer ids
$sessionId = $null; $donacionId = $null
if ($resp.sessionId) { $sessionId = $resp.sessionId } elseif ($resp.donacion -and $resp.donacion.stripeSessionId) { $sessionId = $resp.donacion.stripeSessionId }
if ($resp.donacion -and $resp.donacion.idDonacion) { $donacionId = $resp.donacion.idDonacion } elseif ($resp.donacion -and $resp.donacion.id_donacion) { $donacionId = $resp.donacion.id_donacion }
Write-Host "[e2e] sessionId=$sessionId  donacionId=$donacionId"

# Postgres container
$pg = (docker ps --format '{{.Names}}' | Select-String -Pattern 'postgres' | Select-Object -First 1)
if ($pg) { $pg = $pg.ToString().Trim() } else { $pg = 'api-recetas-postgres' }
Write-Host "[e2e] Usando contenedor Postgres: $pg"

Write-Host "[e2e] Consultas DB antes del webhook:"
docker exec -i $pg psql -U postgres -d api_recetas_postgres -c "SELECT id_donacion, id_usr, amount, currency, status, stripe_session_id, stripe_payment_intent, fecha_creacion FROM donacion ORDER BY fecha_creacion DESC LIMIT 5;"
docker exec -i $pg psql -U postgres -d api_recetas_postgres -c "SELECT id_sesion, session_id, provider, status, id_donacion, metadata, fecha_creacion FROM sesion_pago ORDER BY fecha_creacion DESC LIMIT 5;"

if (-not $sessionId) { Write-Error "No sessionId obtenido, abortando webhook"; if ($pid) { Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue } ; if ($batPath) { Remove-Item $batPath -ErrorAction SilentlyContinue } ; CleanupAndExit 1 }

# Enviar webhook simulado
$evt = @{ id = "evt_test_$(Get-Random)"; type = "checkout.session.completed"; data = @{ object = @{ id = $sessionId; payment_intent = "pi_test_$(Get-Random)"; metadata = @{ donacion_id = (if ($donacionId) { $donacionId } else { "null" }) } } } }
$json = $evt | ConvertTo-Json -Depth 10
Write-Host "[e2e] Enviando webhook simulado..."
try { $wh = Invoke-RestMethod -Method Post -Uri 'http://localhost:8081/webhook/stripe' -Body $json -ContentType 'application/json' -TimeoutSec 30; Write-Host "[e2e] Webhook respuesta: $($wh | ConvertTo-Json -Depth 3)" } catch { Write-Warning "Error webhook: $_" }

Write-Host "[e2e] Consultas DB despues del webhook:"
docker exec -i $pg psql -U postgres -d api_recetas_postgres -c "SELECT id_donacion, id_usr, amount, currency, status, stripe_session_id, stripe_payment_intent, fecha_creacion FROM donacion ORDER BY fecha_creacion DESC LIMIT 5;"
docker exec -i $pg psql -U postgres -d api_recetas_postgres -c "SELECT id_sesion, session_id, provider, status, id_donacion, metadata, fecha_creacion FROM sesion_pago ORDER BY fecha_creacion DESC LIMIT 5;"

Write-Host "[e2e] Limpieza"
if ($pid) { Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue }
if ($batPath) { Remove-Item $batPath -ErrorAction SilentlyContinue }
Write-Host "[e2e] Completado"
    if (-not $sessionId) { Write-Error "No sessionId obtenido, abortando webhook"; Stop-Process -Id $pid -Force; Remove-Item $batPath -ErrorAction SilentlyContinue; exit 1 }

    # Enviar webhook simulado
    $payload = @{ id = "evt_test_$(Get-Random)"; type = "checkout.session.completed"; data = @{ object = @{ id = $sessionId; payment_intent = "pi_test_$(Get-Random)"; metadata = @{ donacion_id = (if ($donacionId) { $donacionId } else { "null" }) } } } }
    $json = $payload | ConvertTo-Json -Depth 10
    Write-Host "[e2e] Enviando webhook simulado..."
    try {
        $wh = Invoke-RestMethod -Method Post -Uri 'http://localhost:8081/webhook/stripe' -Body $json -ContentType 'application/json' -TimeoutSec 30
        Write-Host "[e2e] Webhook enviado, respuesta: $($wh | ConvertTo-Json -Depth 3)"
    } catch { Write-Warning "Error webhook: $_" }

    Write-Host "[e2e] Consultas DB despues del webhook:"
    docker exec -i $pg psql -U postgres -d api_recetas_postgres -c "SELECT id_donacion, id_usr, amount, currency, status, stripe_session_id, stripe_payment_intent, fecha_creacion FROM donacion ORDER BY fecha_creacion DESC LIMIT 5;"
    docker exec -i $pg psql -U postgres -d api_recetas_postgres -c "SELECT id_sesion, session_id, provider, status, id_donacion, metadata, fecha_creacion FROM sesion_pago ORDER BY fecha_creacion DESC LIMIT 5;"

    Write-Host "[e2e] Deteniendo backend (PID=$pid) y limpiando..."
    Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
    Remove-Item $batPath -ErrorAction SilentlyContinue
    Write-Host "[e2e] Completado"
