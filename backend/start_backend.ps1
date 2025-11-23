<#
start_backend.ps1 - MEJORADO
Uso: desde la raíz del repo ejecutar:
  powershell -NoProfile -ExecutionPolicy Bypass -File .\start_backend.ps1 [-NoBuild]

Este script hace:
- para procesos java que estén ejecutando el JAR del backend (api-recetas-0.0.1-SNAPSHOT.jar)
  los detiene limpiamente
- opcionalmente ejecuta `mvn -DskipTests package` en la carpeta Springboot (a menos que pase -NoBuild)
- arranca el JAR en background y redirige stdout/stderr a Springboot\app_out.log y app_err.log
- muestra las últimas líneas de logs con formato mejorado
#>

param(
    [switch]$NoBuild
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$springbootDir = Join-Path $scriptDir 'Springboot'
$jarPath = Join-Path $springbootDir 'target\api-recetas-0.0.1-SNAPSHOT.jar'
$outLog = Join-Path $springbootDir 'app_out.log'
$errLog = Join-Path $springbootDir 'app_err.log'

Write-Host "[start_backend] scriptDir:" $scriptDir
Write-Host "[start_backend] springbootDir:" $springbootDir

# 1) Detener procesos java que ejecuten el JAR específico (si existen)
try {
    $javaProcs = Get-CimInstance Win32_Process -Filter "Name = 'java.exe'" -ErrorAction SilentlyContinue | Where-Object { 
        $_.CommandLine -and ($_.CommandLine -like '*api-recetas-0.0.1-SNAPSHOT.jar*') 
    }
    if ($javaProcs -and $javaProcs.Count -gt 0) {
        Write-Host "[start_backend] [STOP] Deteniendo $($javaProcs.Count) proceso(s) Java que ejecutan el JAR..." -ForegroundColor Yellow
        foreach ($p in $javaProcs) {
            $cmdLineShort = ($p.CommandLine -replace '\s+', ' ')
            if ($cmdLineShort.Length -gt 100) {
                $cmdLineShort = $cmdLineShort.Substring(0, 100) + "..."
            }
            Write-Host "  [KILL] Deteniendo PID $($p.ProcessId): $cmdLineShort" -ForegroundColor Red
            Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
        }
        Start-Sleep -Seconds 2
        Write-Host "[start_backend] [OK] Procesos Java detenidos exitosamente" -ForegroundColor Green
    } else {
        Write-Host "[start_backend] [INFO] No se detectaron procesos Java ejecutando el JAR específico" -ForegroundColor Cyan
    }
} catch {
    Write-Warning "[start_backend] [ERROR] Error al intentar detener procesos Java: $_"
}

# 2) Build opcional
if (-not $NoBuild) {
    if (Test-Path (Join-Path $springbootDir 'pom.xml')) {
        Write-Host "[start_backend] [BUILD] Compilando proyecto Spring Boot..." -ForegroundColor Magenta
        Write-Host "                        Directorio: $springbootDir"
        Push-Location $springbootDir
        try {
            Write-Host "                        Ejecutando: mvn -DskipTests package" -ForegroundColor Cyan
            & mvn -DskipTests package
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[start_backend] [OK] Compilación exitosa!" -ForegroundColor Green
            } else {
                Write-Warning "[start_backend] [WARN] Compilación falló (código: $LASTEXITCODE), intentando usar JAR existente"
            }
        } catch {
            Write-Warning "[start_backend] [ERROR] Maven falló: $_"
            Write-Host "[start_backend] [RETRY] Intentando usar el JAR existente..." -ForegroundColor Yellow
        }
        Pop-Location
    } else {
        Write-Warning "[start_backend] [WARN] No se encontró pom.xml en $springbootDir, omitiendo build."
    }
} else {
    Write-Host "[start_backend] [SKIP] Omitiendo compilación (flag -NoBuild especificado)" -ForegroundColor Yellow
}

# 3) Verificar JAR
Write-Host "[start_backend] [CHECK] Verificando JAR..." -ForegroundColor Cyan
if (!(Test-Path $jarPath)) {
    Write-Error "[start_backend] [ERROR] JAR no encontrado: $jarPath"
    Write-Host "                        Ejecuta primero: mvn -DskipTests package" -ForegroundColor Yellow
    exit 1
}

# Obtener información del JAR
$jarInfo = Get-Item $jarPath
$jarSizeMB = [math]::Round($jarInfo.Length / 1MB, 2)
Write-Host "[start_backend] [JAR] Archivo: $($jarInfo.Name)" -ForegroundColor Green
Write-Host "                      Tamaño: $jarSizeMB MB"
Write-Host "                      Modificado: $($jarInfo.LastWriteTime)"

# 4) Arrancar JAR en background redirigiendo logs
Write-Host "[start_backend] [START] Iniciando Spring Boot Application..." -ForegroundColor Magenta
Write-Host "                        Directorio trabajo: $springbootDir"
Write-Host "                        Logs salida: $outLog"
Write-Host "                        Logs error: $errLog"

# Asegurar logs existentes con separadores
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
try { 
    if (Test-Path $outLog) { 
        Add-Content -Path $outLog -Value "`n`n==== RESTART - $timestamp ====`n" 
    } 
} catch {}
try { 
    if (Test-Path $errLog) { 
        Add-Content -Path $errLog -Value "`n`n==== RESTART - $timestamp ====`n" 
    } 
} catch {}

$startInfo = Start-Process -FilePath 'java' -ArgumentList ('-jar', ("`"" + $jarPath + "`"")) -WorkingDirectory $springbootDir -NoNewWindow -RedirectStandardOutput $outLog -RedirectStandardError $errLog -PassThru
Write-Host "[start_backend] [OK] Proceso iniciado exitosamente!" -ForegroundColor Green
Write-Host "                     PID: $($startInfo.Id)"
Write-Host "                     Esperando inicialización (5 segundos)..."

Start-Sleep -Seconds 5

# 5) Mostrar logs recientes y estado
Write-Host ""
Write-Host "[start_backend] [LOGS] Mostrando logs de inicio..." -ForegroundColor Cyan
Write-Host "==============================================="

Write-Host ""
Write-Host "[SALIDA ESTÁNDAR] (últimas 30 líneas):" -ForegroundColor Green
if (Test-Path $outLog) { 
    $outputLines = Get-Content $outLog -Tail 30
    if ($outputLines) {
        $outputLines | ForEach-Object { Write-Host "   $_" }
    } else {
        Write-Host "   (archivo vacío)"
    }
} else { 
    Write-Host "   (archivo no existe aún: $outLog)" 
}

Write-Host ""
Write-Host "[ERRORES] (últimas 15 líneas):" -ForegroundColor Red
if (Test-Path $errLog) { 
    $errorLines = Get-Content $errLog -Tail 15
    if ($errorLines) {
        $errorLines | ForEach-Object { Write-Host "   $_" -ForegroundColor Yellow }
    } else {
        Write-Host "   (sin errores)" -ForegroundColor Green
    }
} else { 
    Write-Host "   (archivo de errores no existe aún: $errLog)" 
}

Write-Host ""
Write-Host "==============================================="
Write-Host "[SUCCESS] BACKEND SPRING BOOT INICIADO" -ForegroundColor Green
Write-Host "   PID del proceso: $($startInfo.Id)"
Write-Host "   URL probable: http://localhost:8080"
Write-Host "   Swagger UI: http://localhost:8080/swagger-ui.html"
Write-Host "   Para detener: Stop-Process -Id $($startInfo.Id)"
Write-Host "   Logs en tiempo real: Get-Content '$outLog' -Wait"
Write-Host "==============================================="