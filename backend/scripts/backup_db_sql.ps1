# Backup DB in plain SQL format from container and copy to host
$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$dumpInContainer = "/tmp/db_backup_$ts.sql"
$dumpOnHost = "backups/db_backup_$ts.sql"
Write-Output "STARTING_DB_DUMP_SQL:$ts"
# Run pg_dump inside container as postgres user (plain SQL)
docker exec -u postgres api-recetas-postgres pg_dump -d api_recetas_postgres -Fp -f $dumpInContainer
if ($LASTEXITCODE -ne 0) { Write-Error "PG_DUMP_FAILED"; exit 3 }
# Copy dump to host
docker cp api-recetas-postgres:$dumpInContainer $dumpOnHost
if ($LASTEXITCODE -ne 0) { Write-Error "DOCKER_CP_FAILED"; exit 4 }
# Remove temp dump in container
docker exec api-recetas-postgres rm $dumpInContainer
# Report file size
$h = Get-Item $dumpOnHost
Write-Output "DB_DUMP_SQL_CREATED:$dumpOnHost"
Write-Output "DB_DUMP_SQL_SIZE:$($h.Length)"
