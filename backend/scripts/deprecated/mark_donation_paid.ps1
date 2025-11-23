param(
    [Parameter(Mandatory=$true)] [string] $SessionId
)

$pg = (docker ps --format '{{.Names}}' | Select-String -Pattern 'postgres' | Select-Object -First 1)
if ($pg) { $pg = $pg.ToString().Trim() } else { $pg = 'api-recetas-postgres' }
Write-Host "Usando contenedor Postgres: $pg"

# Buscar donacion por stripe_session_id
$q1 = "SELECT id_donacion FROM donacion WHERE stripe_session_id = '$SessionId' LIMIT 1;"
$res = docker exec -i $pg psql -U postgres -d api_recetas_postgres -t -c "$q1" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
if (-not $res) {
    Write-Host "No se encontró donacion con stripe_session_id=$SessionId" -ForegroundColor Yellow
    exit 1
}
$idDon = $res[0]
Write-Host "Found donacion id: $idDon"

# Actualizar donacion a PAID
$q2 = "UPDATE donacion SET status='PAID', stripe_payment_intent = COALESCE(stripe_payment_intent, 'manual_mark_paid') WHERE id_donacion = $idDon;"
docker exec -i $pg psql -U postgres -d api_recetas_postgres -c "$q2"

# Crear o actualizar sesion_pago
$q3 = "SELECT id_sesion FROM sesion_pago WHERE session_id = '$SessionId' LIMIT 1;"
$res2 = docker exec -i $pg psql -U postgres -d api_recetas_postgres -t -c "$q3" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
if ($res2) {
    $idSesion = $res2[0]
    Write-Host "Actualizando sesion_pago id: $idSesion" -ForegroundColor Green
    $q4 = "UPDATE sesion_pago SET status='PAID', id_donacion = $idDon WHERE id_sesion = $idSesion;"
    docker exec -i $pg psql -U postgres -d api_recetas_postgres -c "$q4"
} else {
    Write-Host "Creando nuevo registro sesion_pago para session_id=$SessionId" -ForegroundColor Green
    $q5 = "INSERT INTO sesion_pago (session_id, provider, status, id_donacion, metadata) VALUES ('$SessionId','stripe','PAID',$idDon,'{}');"
    docker exec -i $pg psql -U postgres -d api_recetas_postgres -c "$q5"
}

Write-Host "Hecho. Verifica la tabla donacion y sesion_pago." -ForegroundColor Cyan
