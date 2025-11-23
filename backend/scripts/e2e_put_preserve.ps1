# E2E: Verificar preservación en PUT {}
# Requisitos: tener backend en http://localhost:8081 y usuario admin@recetas.com / cast1301

function Get-Token {
    param($email, $password)
    $body = @{ email = $email; password = $password } | ConvertTo-Json -Depth 6
    $resp = Invoke-RestMethod -Uri 'http://localhost:8081/auth/login' -Method Post -ContentType 'application/json' -Body $body
    if ($null -ne $resp.token) { return $resp.token }
    if ($null -ne $resp.data -and $null -ne $resp.data.token) { return $resp.data.token }
    return $null
}

function Extract-Fecha {
    param($json)
    if (-not $json) { return $null }
    $m = [regex]::Match($json, '"fechaCreacion"\s*:\s*"([^"]+)"')
    if ($m.Success) { return $m.Groups[1].Value } else { return $null }
}

function Test-PutPreserve {
    param($path, $idField)
    Write-Host "\n--- Probando $path ---"
    try {
        $listResp = Invoke-RestMethod -Uri "http://localhost:8081/$path" -Method Get -Headers $Headers -ErrorAction Stop
        $items = @()
        if ($listResp -is [System.Collections.IEnumerable]) { $items = $listResp } else { $items = @($listResp) }
        if ($items.Count -eq 0) {
            Write-Host "No hay elementos en $path. Saltando."
            return
        }
        $first = $items[0]
        # Obtener id dinámicamente
        $id = $null
        if ($first.PSObject.Properties.Name -contains $idField) { $id = $first.$idField } else {
            # intentar variantes comunes
            foreach ($p in $first.PSObject.Properties) { if ($p.Name -match 'id') { $id = $p.Value; break } }
        }
        if (-not $id) { Write-Host "No pude determinar id para $path"; return }
        $beforeJson = $first | ConvertTo-Json -Depth 10
        $beforeFecha = Extract-Fecha $beforeJson
        Write-Host "ID = $id, fechaAntes = $beforeFecha"

        # Hacer PUT con body vacío
        $put = Invoke-RestMethod -Uri "http://localhost:8081/$path/$id" -Method Put -ContentType 'application/json' -Headers $Headers -Body '{}' -ErrorAction Stop
        $afterJson = $put | ConvertTo-Json -Depth 10
        $afterFecha = Extract-Fecha $afterJson
        Write-Host "fechaDespues = $afterFecha"

        if ($beforeFecha -eq $afterFecha) {
            Write-Host "OK: fechaCreacion preservada para $path/$id" -ForegroundColor Green
        } else {
            Write-Host "ERROR: fechaCreacion cambió para $path/$id" -ForegroundColor Red
        }
    } catch {
        Write-Host ("Error durante test " + $path + ": " + $_.ToString()) -ForegroundColor Yellow
    }
}

# Inicio
Write-Host "Iniciando E2E PUT preserve tests..."
$token = Get-Token -email 'admin@recetas.com' -password 'cast1301'
if (-not $token) { Write-Host 'No se obtuvo token. Abortando.'; exit 1 }
$Headers = @{ Authorization = "Bearer $token" }

# Rutas a probar: admin/comentarios, admin/favoritos, admin/megusta, admin/estrellas
Test-PutPreserve 'admin/comentarios' 'idComentario'
Test-PutPreserve 'admin/favoritos' 'idFav'
Test-PutPreserve 'admin/megusta' 'idMeGusta'
Test-PutPreserve 'admin/estrellas' 'idEstrella'

Write-Host "\nE2E PUT preserve tests finalizados."