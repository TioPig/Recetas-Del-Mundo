Set-Location 'c:\GitHub\api-recetas_final\backend'

# Build the backend image
docker compose build backend

# Start Postgres only if the container does not already exist
$pgExists = (& docker ps -a --filter "name=api-recetas-postgres" --format "{{.Names}}")
if ([string]::IsNullOrEmpty($pgExists)) {
  Write-Host 'Starting Postgres...'
  docker compose up -d postgres
} else {
  Write-Host 'Postgres container already exists; not recreating.'
}

Write-Host 'Waiting for Postgres...'
for ($i=0; $i -lt 30; $i++) {
  docker exec api-recetas-postgres pg_isready -U postgres > $null 2>&1
  if ($LASTEXITCODE -eq 0) { Write-Host 'Postgres ready'; break }
  Start-Sleep -Seconds 2
}

Write-Host 'Applying migration (if file exists on host)'
$migPath = Join-Path (Get-Location) 'database\migrations\V20251124_change_donacion_amount_to_numeric.sql'
if (Test-Path $migPath) {
  Get-Content $migPath -Raw | docker exec -i api-recetas-postgres psql -U postgres -d api_recetas_postgres -v ON_ERROR_STOP=1 -f - 2>&1 | Write-Host
} else {
  Write-Host "Migration file not found at: $migPath; skipping."
}

# If the DB was fresh, ensure initial data (users) exist by importing init.sql
Write-Host 'Checking for existing users in DB...'
$userCount = docker exec -i api-recetas-postgres psql -U postgres -d api_recetas_postgres -t -A -c "SELECT count(*) FROM usuario;" 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($userCount)) {
  Write-Host 'Could not read usuario count (table may not exist yet). Will attempt to import init.sql.'
  $shouldImport = $true
} else {
  try {
    $cnt = [int]$userCount.Trim()
    if ($cnt -eq 0) { $shouldImport = $true } else { $shouldImport = $false }
  } catch {
    $shouldImport = $true
  }
}
if ($shouldImport) {
  $initPath = Join-Path (Get-Location) 'database\init.sql'
  if (Test-Path $initPath) {
    Write-Host "Importing initial data from $initPath..."
    Get-Content $initPath -Raw | docker exec -i api-recetas-postgres psql -U postgres -d api_recetas_postgres -v ON_ERROR_STOP=1 -f - 2>&1 | Write-Host
  } else {
    Write-Host "init.sql not found at: $initPath; skipping initial import."
  }
} else {
  Write-Host "Users already present in DB (count: $cnt); skipping init import."
}

Write-Host 'Starting backend...'
docker compose up -d backend

Write-Host 'Waiting for backend (actuator/health)...'
for ($i=0; $i -lt 60; $i++) {
  try {
    $h = Invoke-RestMethod -UseBasicParsing -Uri 'http://localhost:8081/actuator/health' -Method GET -TimeoutSec 5
    if ($h.status -eq 'UP') { Write-Host 'Backend UP'; break }
  } catch {
    Start-Sleep -Seconds 2
  }
}

Write-Host 'Logging in as admin@recetas.com'
try {
  $login = Invoke-RestMethod -Method Post -Uri 'http://localhost:8081/auth/login' -Body (ConvertTo-Json @{ email='admin@recetas.com'; password='cast1301' }) -ContentType 'application/json' -TimeoutSec 10
} catch {
  Write-Host "Login error: $_"; exit 1
}
$token = $login.token
Write-Host "TOKEN: $token"

$amounts = @(5,11,1235)
foreach ($a in $amounts) {
  Write-Host ""
  Write-Host "--- Creating donation session for: $a USD ---"
  $body = @{ amount = $a; currency = 'usd' } | ConvertTo-Json
  try {
    $resp = Invoke-RestMethod -Method Post -Uri 'http://localhost:8081/donaciones/create-session' -Body $body -ContentType 'application/json' -Headers @{ Authorization = "Bearer $token" } -TimeoutSec 30
    Write-Host ($resp | ConvertTo-Json -Depth 5)
  } catch {
    Write-Host ("Error creating session for {0}: {1}" -f $a, $_.Exception.Message)
  }
}

Write-Host ""
Write-Host "-- Recent donations --"
docker exec -i api-recetas-postgres psql -U postgres -d api_recetas_postgres -c "SELECT id_donacion, id_usr, amount, currency, status, stripe_session_id, fecha_creacion FROM donacion ORDER BY id_donacion DESC LIMIT 10;"

Write-Host ""
Write-Host "-- Recent payment sessions --"
docker exec -i api-recetas-postgres psql -U postgres -d api_recetas_postgres -c "SELECT id_sesion, session_id, provider, status, id_donacion, metadata, fecha_creacion FROM sesion_pago ORDER BY id_sesion DESC LIMIT 10;"
