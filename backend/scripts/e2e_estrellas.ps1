# E2E script: agregar, modificar y eliminar una calificacion (estrellas)
# Uso: .\e2e_estrellas.ps1
$base = 'http://localhost:8081'
$creds = @{ email = 'admin@recetas.com'; password = 'cast1301' } | ConvertTo-Json

function Get-Token {
    try {
        $login = Invoke-RestMethod -Uri "$base/auth/login" -Method Post -ContentType 'application/json' -Body $creds -ErrorAction Stop
    } catch {
        Write-Host "LOGIN ERROR: $_.Exception.Message"
        if ($_.Exception.Response) { $s=(New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd(); Write-Host 'BODY:'; Write-Host $s }
        exit 1
    }
    if ($null -ne $login.token) { return $login.token }
    if ($login.data -and $login.data.token) { return $login.data.token }
    throw 'No token in login response'
}

$token = Get-Token
$headers = @{ Authorization = "Bearer $token" }

# Decode token payload helper (safe)
function Decode-JwtPayload($jwt) {
    $parts = $jwt -split '\.'
    if ($parts.Length -lt 2) { return $null }
    $payload = $parts[1]
    switch ($payload.Length % 4) { 2 { $payload += '==' } 3 { $payload += '=' } default { } }
    try {
        $bytes = [System.Convert]::FromBase64String($payload)
        $json = [System.Text.Encoding]::UTF8.GetString($bytes)
        return $json | ConvertFrom-Json
    } catch { return $null }
}

# Extract user id from token (avoid hardcoding)
$idUsuario = $null
$payload = Decode-JwtPayload $token
if ($payload) {
    if ($payload.id_usr) { $idUsuario = $payload.id_usr }
    elseif ($payload.idUsr) { $idUsuario = $payload.idUsr }
    elseif ($payload.sub) { $idUsuario = $payload.sub }
}
if (-not $idUsuario) {
    Write-Host "Warning: no user id found in token; falling back to 1"
    $idUsuario = 1
}

# Buscar una receta existente para usar en la prueba
Write-Host "-> Buscando una receta existente via GET /recetas"
try {
    $allRec = Invoke-RestMethod -Uri "$base/recetas" -Method Get -ErrorAction Stop
} catch {
    Write-Host "ERROR al listar recetas: $_.Exception.Message"
    if ($_.Exception.Response) { $s=(New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd(); Write-Host 'BODY:'; Write-Host $s }
    exit 1
}

$idReceta = $null
if ($allRec -and $allRec.data -and $allRec.data.Count -gt 0) {
    $first = $allRec.data[0]
    # intentar varias propiedades posibles
    $possible = @('idReceta','id_receta','id','idRecet')
    foreach ($p in $possible) {
        try {
            $val = $first.$p
        } catch { $val = $null }
        if ($val) { $idReceta = $val; break }
    }
}
if (-not $idReceta) {
    Write-Host "No se encontró ninguna receta válida para usar en la prueba. Abortando."
    exit 1
}
Write-Host "Usando receta id=$idReceta para la prueba"

# 1) Agregar calificacion 4
$estrellas = 4
Write-Host "-> Agregando calificacion $estrellas para receta $idReceta"
try {
    $add = Invoke-RestMethod -Uri "$base/recetas/estrellas?idUsuario=$idUsuario&idReceta=$idReceta&estrellas=$estrellas" -Method Post -Headers $headers -ErrorAction Stop
    $add | ConvertTo-Json -Depth 6 | Write-Host
} catch {
    Write-Host "ADD ERROR: $_.Exception.Message"
    if ($_.Exception.Response) { $s=(New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd(); Write-Host 'BODY:'; Write-Host $s }
    exit 1
}

# 2) Actualizar a 3 (PUT /recetas/estrellas/{id}?estrellas=3)
# necesitamos el id de la calificacion (vino en add.data o add.data.idEstrella)
$calificacionId = $null
if ($add.data -and $add.data.idEstrella) { $calificacionId = $add.data.idEstrella }
if (-not $calificacionId -and $add.data -and $null -ne $add.data.id) { $calificacionId = $add.data.id }
if (-not $calificacionId) { Write-Host "No se obtuvo id de calificacion en la respuesta"; exit 1 }

$newValue = 3
Write-Host "-> Actualizando calificacion id=$calificacionId a $newValue"
try {
    $calificacionId = [string]$calificacionId
    $url = $base + "/recetas/estrellas/" + $calificacionId + "?estrellas=" + $newValue
    Write-Host "PUT URL: $url"
    $update = Invoke-RestMethod -Uri $url -Method Put -Headers $headers -ErrorAction Stop
    $update | ConvertTo-Json -Depth 6 | Write-Host
} catch {
    Write-Host "UPDATE ERROR: $_.Exception.Message"
    if ($_.Exception.Response) { $s=(New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd(); Write-Host 'BODY:'; Write-Host $s }
    exit 1
}

# 3) Eliminar calificacion
Write-Host "-> Eliminando calificacion id=$calificacionId"
try {
    $del = Invoke-RestMethod -Uri "$base/recetas/estrellas/$calificacionId" -Method Delete -Headers $headers -ErrorAction Stop
    $del | ConvertTo-Json -Depth 6 | Write-Host
} catch {
    Write-Host "DELETE ERROR: $_.Exception.Message"
    if ($_.Exception.Response) { $s=(New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd(); Write-Host 'BODY:'; Write-Host $s }
    exit 1
}

# Verificar con GET /recetas/estrellas (contextual)
Write-Host "-> Verificando calificaciones del usuario autenticado"
try {
    $list = Invoke-RestMethod -Uri "$base/recetas/estrellas" -Method Get -Headers $headers -ErrorAction Stop
    $list | ConvertTo-Json -Depth 8 | Write-Host
} catch {
    Write-Host "LIST ERROR: $_.Exception.Message"
    if ($_.Exception.Response) { $s=(New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd(); Write-Host 'BODY:'; Write-Host $s }
    exit 1
}

Write-Host "E2E estrellas test completed."