Param(
    [int]$RetentionDays = 7
)

$ErrorActionPreference = 'Stop'

function Write-Info($msg){ Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Ok($msg){ Write-Host "[OK]   $msg" -ForegroundColor Green }
function Write-Warn($msg){ Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err($msg){ Write-Host "[ERROR] $msg" -ForegroundColor Red }

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Resolve-Path (Join-Path $ScriptDir '..') | Select-Object -ExpandProperty Path
$BackupRoot = Join-Path $RootDir 'backups'
New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$staging = Join-Path $env:TEMP "recetas_backup_$timestamp"
New-Item -ItemType Directory -Force -Path $staging | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $staging 'database') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $staging 'volumes') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $staging 'docker') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $staging 'config') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $staging 'artifacts') | Out-Null

Write-Info "Raíz repo: $RootDir"
Write-Info "Carpeta backups: $BackupRoot"
Write-Info "Timestamp: $timestamp"

# Cargar .env si existe
$envFile = Join-Path $RootDir '.env'
if (Test-Path $envFile) {
  Write-Info "Cargando variables desde .env"
  Get-Content $envFile | ForEach-Object {
    $line = $_.Trim()
    if (-not $line -or $line.StartsWith('#')) { return }
    $idx = $line.IndexOf('=')
    if ($idx -gt 0) {
      $k = $line.Substring(0,$idx).Trim()
      $v = $line.Substring($idx+1).Trim('"').Trim()
  if ($k) { Set-Item -Path ("Env:{0}" -f $k) -Value $v }
    }
  }
}

# Defaults del compose
$POSTGRES_CONTAINER_NAME = $env:POSTGRES_CONTAINER_NAME; if (-not $POSTGRES_CONTAINER_NAME) { $POSTGRES_CONTAINER_NAME = 'api-recetas-postgres' }
$PGADMIN_CONTAINER_NAME   = $env:PGADMIN_CONTAINER_NAME;   if (-not $PGADMIN_CONTAINER_NAME)   { $PGADMIN_CONTAINER_NAME = 'api-recetas-pgadmin' }
$BACKEND_IMAGE_NAME       = $env:BACKEND_IMAGE_NAME;       if (-not $BACKEND_IMAGE_NAME)       { $BACKEND_IMAGE_NAME = 'api-recetas_final-backend:latest' }
$POSTGRES_VOLUME          = $env:POSTGRES_VOLUME;          if (-not $POSTGRES_VOLUME)          { $POSTGRES_VOLUME = 'postgres_data' }
$PGADMIN_VOLUME           = $env:PGADMIN_VOLUME;           if (-not $PGADMIN_VOLUME)           { $PGADMIN_VOLUME = 'pgadmin_data' }

$POSTGRES_DB       = $env:POSTGRES_DB;       if (-not $POSTGRES_DB)       { $POSTGRES_DB = 'api_recetas_postgres' }
$POSTGRES_USER     = $env:POSTGRES_USER;     if (-not $POSTGRES_USER)     { $POSTGRES_USER = 'postgres' }
$POSTGRES_PASSWORD = $env:POSTGRES_PASSWORD  # puede ser null

# Resolver nombres reales de volúmenes creados por docker compose (suele usar <carpeta>_volumen)
try {
  $projectName = Split-Path $RootDir -Leaf
  $allVolumes = @()
  try { $allVolumes = docker volume ls --format '{{.Name}}' 2>$null } catch {}

  # Helper para resolver un volumen por candidatos
  function Resolve-VolumeName([string]$requested, [string]$suffix) {
    if (-not $allVolumes -or $allVolumes.Count -eq 0) { return $requested }
    if ($allVolumes -contains $requested) { return $requested }
    $candidates = @(
      ("{0}_{1}" -f $projectName, $suffix),
      ("{0}-{1}" -f $projectName, $suffix),
      $suffix
    )
    foreach ($c in $candidates) { if ($allVolumes -contains $c) { return $c } }
    return $requested
  }

  $POSTGRES_VOLUME = Resolve-VolumeName -requested $POSTGRES_VOLUME -suffix 'postgres_data'
  $PGADMIN_VOLUME  = Resolve-VolumeName -requested $PGADMIN_VOLUME  -suffix 'pgadmin_data'

  Write-Info ("Volúmenes detectados -> postgres: {0} | pgadmin: {1}" -f $POSTGRES_VOLUME, $PGADMIN_VOLUME)
} catch { Write-Warn "No se pudieron resolver nombres de volúmenes automáticamente: $($_.Exception.Message)" }

# 1) Dump DB
$dumpSql = Join-Path (Join-Path $staging 'database') ("pgdump_{0}_{1}.sql" -f $POSTGRES_DB,$timestamp)
Write-Info "Generando dump Postgres desde $POSTGRES_CONTAINER_NAME (db=$POSTGRES_DB user=$POSTGRES_USER)"
try {
  if ($POSTGRES_PASSWORD) {
    $env:PGPASSWORD = $POSTGRES_PASSWORD
    docker exec $POSTGRES_CONTAINER_NAME sh -lc "pg_dump -U '$POSTGRES_USER' -d '$POSTGRES_DB'" | Set-Content -Path $dumpSql -Encoding UTF8
    Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
  } else {
    docker exec $POSTGRES_CONTAINER_NAME sh -lc "pg_dump -U '$POSTGRES_USER' -d '$POSTGRES_DB'" | Set-Content -Path $dumpSql -Encoding UTF8
  }
  Write-Ok "Dump DB: $dumpSql"
}
catch {
  Write-Warn "No se pudo generar dump de DB: $($_.Exception.Message)"
}

# 2) Volúmenes nombrados
Write-Info "Respaldando volúmenes Docker"
$volDir = Join-Path $staging 'volumes'
try {
  docker volume inspect $POSTGRES_VOLUME *>$null
  docker run --rm -v "${POSTGRES_VOLUME}:/volume" -v "${volDir}:/backup" alpine sh -c "tar -czf /backup/${POSTGRES_VOLUME}_${timestamp}.tar.gz -C /volume ."
  Write-Ok "Volumen $POSTGRES_VOLUME respaldado"
} catch { Write-Warn "Volumen $POSTGRES_VOLUME no existe o no accesible" }

try {
  docker volume inspect $PGADMIN_VOLUME *>$null
  docker run --rm -v "${PGADMIN_VOLUME}:/volume" -v "${volDir}:/backup" alpine sh -c "tar -czf /backup/${PGADMIN_VOLUME}_${timestamp}.tar.gz -C /volume ."
  Write-Ok "Volumen $PGADMIN_VOLUME respaldado"
} catch { Write-Warn "Volumen $PGADMIN_VOLUME no existe o no accesible" }

# 3) Imágenes Docker
Write-Info "Guardando imágenes del stack"
$composeFile = Join-Path $RootDir 'docker-compose.yml'
$images = @()
try {
  # Preferir repository:tag para evitar IDs crudos que generan errores
  $images = docker compose -f $composeFile images --format "{{.Repository}}:{{.Tag}}" 2>$null |
            Where-Object { $_ -and ($_ -notmatch '<none>') } |
            Sort-Object -Unique
} catch { }
if (-not $images -or $images.Count -eq 0) {
  $images = @('postgres:15-alpine','dpage/pgadmin4:8.11', $BACKEND_IMAGE_NAME)
}
Write-Info ("Imágenes: {0}" -f ($images -join ', '))
$imagesTar = Join-Path (Join-Path $staging 'docker') ("images_{0}.tar" -f $timestamp)
try {
  docker save -o $imagesTar $images
  if (Test-Path $imagesTar) {
    $size = (Get-Item $imagesTar).Length
    if ($size -gt 0) { Write-Ok "Imágenes guardadas: $imagesTar ($([Math]::Round($size/1MB,2)) MB)" }
    else { Write-Warn "El archivo de imágenes se creó pero está vacío: $imagesTar" }
  } else {
    Write-Warn "El archivo de imágenes no se creó: $imagesTar"
  }
} catch { Write-Warn "No se pudieron guardar todas las imágenes: $($_.Exception.Message)" }

# 4) Configs
Write-Info "Copiando configuración"
Copy-Item -Path $composeFile -Destination (Join-Path $staging 'config') -ErrorAction SilentlyContinue
if (Test-Path (Join-Path $RootDir 'pgadmin/servers.json')) { Copy-Item (Join-Path $RootDir 'pgadmin/servers.json') (Join-Path $staging 'config/servers.json') -ErrorAction SilentlyContinue }
if (Test-Path (Join-Path $RootDir 'Springboot/Dockerfile')) { Copy-Item (Join-Path $RootDir 'Springboot/Dockerfile') (Join-Path $staging 'config/Dockerfile') -ErrorAction SilentlyContinue }
if (Test-Path (Join-Path $RootDir 'Springboot/pom.xml')) { Copy-Item (Join-Path $RootDir 'Springboot/pom.xml') (Join-Path $staging 'config/pom.xml') -ErrorAction SilentlyContinue }
if (Test-Path (Join-Path $RootDir 'docker-compose.prod.yml')) { Copy-Item (Join-Path $RootDir 'docker-compose.prod.yml') (Join-Path $staging 'config/docker-compose.prod.yml') -ErrorAction SilentlyContinue }

# 4b) Artefactos (jar de Spring Boot)
try {
  $jarDir = Join-Path $RootDir 'Springboot\target'
  if (Test-Path $jarDir) {
    $jar = Get-ChildItem -Path $jarDir -Filter '*.jar' -File | Where-Object { $_.Name -notlike '*.original' } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($jar) {
      $destJar = Join-Path (Join-Path $staging 'artifacts') $jar.Name
      Copy-Item -Path $jar.FullName -Destination $destJar -Force
      # Checksum SHA256
      try {
        $hash = Get-FileHash -Algorithm SHA256 -Path $destJar
        $hashLine = "{0}  {1}" -f $hash.Hash, $jar.Name
        $hashFile = Join-Path (Join-Path $staging 'artifacts') 'SHA256SUMS.txt'
        $hashLine | Out-File -FilePath $hashFile -Encoding ASCII -Append
      } catch { }
      Write-Ok ("Artefacto incluido: {0}" -f $jar.Name)
    } else {
      Write-Warn 'No se encontró .jar en Springboot/target'
    }
  }
} catch { Write-Warn "No se pudo copiar el .jar: $($_.Exception.Message)" }

# 5) Tar final
$finalTar = Join-Path $BackupRoot ("complete_backup_{0}.tar.gz" -f $timestamp)
Write-Info "Empaquetando: $finalTar"
& tar -C $staging -czf $finalTar .
Write-Ok "Backup generado: $finalTar"

# 6) Retención
Write-Info "Aplicando retención de $RetentionDays días"
Get-ChildItem -Path $BackupRoot -Filter 'complete_backup_*.tar.gz' -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$RetentionDays) } | ForEach-Object {
  Write-Info "Borrando antiguo: $($_.FullName)"
  Remove-Item $_.FullName -Force
}

# 7) Limpieza
Remove-Item -Recurse -Force $staging
Write-Host "[DONE] Respaldo finalizado" -ForegroundColor Green
