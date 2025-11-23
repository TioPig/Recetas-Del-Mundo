# E2E script: crear, modificar y eliminar un comentario en /recetas/comentarios
# Requisitos: PowerShell, backend corriendo en http://localhost:8081
# Uso: .\e2e_comments.ps1

$base = 'http://localhost:8081'
$creds = @{ email = 'admin@recetas.com'; password = 'cast1301' } | ConvertTo-Json

function Get-Token {
    param()
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

# Decode token payload helper
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

# Extract idUsuario from token
$idUsuario = $null
$payload = Decode-JwtPayload $token
if ($payload) {
    if ($payload.id_usr) { $idUsuario = $payload.id_usr }
    elseif ($payload.idUsr) { $idUsuario = $payload.idUsr }
    elseif ($payload.sub) { $idUsuario = $payload.sub }
}
if (-not $idUsuario) { Write-Host "Warning: no user id found in token; falling back to 1"; $idUsuario = 1 }

# Pick a receta dynamically to avoid FK issues
Write-Host "Picking a receta via GET /recetas"
try {
    $recetasResp = Invoke-RestMethod -Uri "$base/recetas" -Method Get -ErrorAction Stop
} catch {
    Write-Host "Failed to list recetas to pick an id: $_.Exception.Message"
    if ($_.Exception.Response) { $s=(New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd(); Write-Host 'BODY:'; Write-Host $s }
    exit 1
}

function Get-FirstRecetaId($recetasObj) {
    if (-not $recetasObj) { return $null }
    $candidate = $null
    if ($recetasObj -is [System.Array] -and $recetasObj.Length -gt 0) { $candidate = $recetasObj[0] }
    elseif ($recetasObj.data -and $recetasObj.data[0]) { $candidate = $recetasObj.data[0] }
    else { $candidate = $recetasObj }
    foreach ($prop in @('idReceta','id_receta','id','idReceta')) {
        if ($candidate.PSObject.Properties.Name -contains $prop) { return $candidate.$prop }
    }
    return $null
}

$idReceta = Get-FirstRecetaId $recetasResp
if (-not $idReceta) { Write-Host 'Could not determine receta id from /recetas response, falling back to 1'; $idReceta = 1 }

# 1) Crear comentario
Write-Host "-> Creando comentario (endpoint espera query params idUsuario,idReceta,texto)..."
try {
    $qs = @{ id_usr = $idUsuario; id_receta = $idReceta; texto = 'Comentario E2E inicial' }
    $url = "$base/recetas/comentarios?id_usr=$($qs.id_usr)&id_receta=$($qs.id_receta)&texto=$( [System.Uri]::EscapeDataString($qs.texto) )"
    $createdResp = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -ErrorAction Stop
    $createdResp | ConvertTo-Json -Depth 10 | Write-Host
} catch {
    Write-Host "CREATE ERROR: $_.Exception.Message"
    if ($_.Exception.Response) { $s=(New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd(); Write-Host 'BODY:'; Write-Host $s }
    exit 1
}

# La respuesta del controlador contiene el objeto creado en data
$commentId = $null
if ($createdResp.data -and $createdResp.data.idComentario) { $commentId = $createdResp.data.idComentario }
if (-not $commentId) { Write-Host "No se pudo obtener idComentario desde response.data"; exit 1 }

# Guardar fechaCreacion original
$origFecha = $createdResp.data.fechaCreacion
Write-Host "Fecha creacion original: $origFecha"

# Helper: normalizar timestamp a 6 decimales (microsegundos) para comparar
function Normalize-Ts {
    param([string]$s)
    if (-not $s) { return $null }
    if ($s -match '\.') {
        $parts = $s.Split('.')
        $frac = $parts[1]
        if ($frac.Length -gt 6) { $frac = $frac.Substring(0,6) }
        elseif ($frac.Length -lt 6) { $frac = $frac.PadRight(6,'0') }
        return "$($parts[0]).$frac"
    } else {
        return "$s.000000"
    }
}

# Mejor manejo de timestamps: aceptar tanto strings ISO como arrays [year,month,day,h,m,s,nanos]
function Normalize-Ts-Flexible {
    param([object]$input)
    if ($null -eq $input) { return $null }

    # Si viene como array de componentes de fecha/hora
    if ($input -is [System.Object[]]) {
        $arr = $input
        if ($arr.Length -lt 7) { return $null }
        $year = $arr[0]; $month = $arr[1]; $day = $arr[2]; $hour = $arr[3]; $min = $arr[4]; $sec = $arr[5]; $nanos = $arr[6]
        # Convertir nanos a microsegundos (6 dígitos) con redondeo
        try {
            $micro = [math]::Round([double]$nanos / 1000)
        } catch {
            $micro = 0
        }
        $microStr = [string]$micro
        if ($microStr.Length -gt 6) { $microStr = $microStr.Substring(0,6) }
        elseif ($microStr.Length -lt 6) { $microStr = $microStr.PadLeft(6,'0') }
        # Construir string normalizado similar a 'yyyy-MM-ddTHH:mm:ss.ffffff'
        $datePart = "{0}-{1:D2}-{2:D2} {3:D2}:{4:D2}:{5:D2}" -f $year, $month, $day, $hour, $min, $sec
        return "$datePart.$microStr"
    }

    # Si es string, reutilizar la función previa
    return Normalize-Ts -s $input
}

 $origFechaNorm = Normalize-Ts-Flexible $origFecha
 Write-Host "Fecha original normalizada: $origFechaNorm"

# 2) Modificar comentario (PUT) - usando JSON body parcial { texto: 'nuevo texto' }
$updateBody = @{ texto = 'Comentario E2E modificado' } | ConvertTo-Json
Write-Host "-> Modificando comentario id=$commentId ..."
try {
    # enviar body JSON opcional { texto: '...' } -> RecetaController acepta JSON body para PUT
    $updatedResp = Invoke-RestMethod -Uri "$base/recetas/comentarios/$commentId" -Method Put -ContentType 'application/json' -Headers $headers -Body $updateBody -ErrorAction Stop
    $updatedResp | ConvertTo-Json -Depth 10 | Write-Host
} catch {
    Write-Host "UPDATE ERROR: $_.Exception.Message"
    if ($_.Exception.Response) { $s=(New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd(); Write-Host 'BODY:'; Write-Host $s }
    exit 1
}

# El objeto actualizado está en updatedResp.data
$updated = $null
if ($updatedResp.data) { $updated = $updatedResp.data }
if (-not $updated) { Write-Host "No se obtuvo el comentario actualizado en response.data"; exit 1 }

 # Verificar preservación de fechaCreacion y claves foraneas
 $updatedFecha = $updated.fechaCreacion
 # comparar con tolerancia de hasta 5 ms para evitar diferencias por redondeo/format
 try {
     $origNorm = Normalize-Ts-Flexible $origFecha
     $updatedNorm = Normalize-Ts-Flexible $updatedFecha
     $dtOrig = [datetime]::Parse($origNorm)
     $dtUpdated = [datetime]::Parse($updatedNorm)
     $diffMs = [math]::Abs((($dtUpdated - $dtOrig).TotalMilliseconds))
 } catch {
     # si no se pueden parsear, fallback a comparación string normalizada
     $updatedFechaNorm = Normalize-Ts-Flexible $updatedFecha
     if ($updatedFechaNorm -ne $origFechaNorm) { Write-Host "ERROR: fechaCreacion no preservada! original=$origFechaNorm nuevo=$updatedFechaNorm"; exit 1 }
     else { Write-Host "OK: fechaCreacion preservada (por normalizacion)" }
 }

 if ($diffMs -gt 5) {
     Write-Host "ERROR: fechaCreacion no preservada (diferencia ms=$diffMs) original=$origFecha nuevo=$updatedFecha"; exit 1
 } else {
     Write-Host "OK: fechaCreacion preservada (diferencia ms=$diffMs)"
 }

if ($updated.receta.idReceta -ne $createdResp.data.receta.idReceta -or $updated.usuario.idUsr -ne $createdResp.data.usuario.idUsr) {
    Write-Host "ERROR: claves foraneas cambiaron (idReceta/idUsr)"; exit 1
} else { Write-Host "OK: claves foraneas preservadas" }

# 3) Eliminar comentario
Write-Host "-> Eliminando comentario id=$commentId ..."
try {
    $delResp = Invoke-RestMethod -Uri "$base/recetas/comentarios/$commentId" -Method Delete -Headers $headers -ErrorAction Stop
    $delResp | ConvertTo-Json -Depth 5 | Write-Host
} catch {
    Write-Host "DELETE ERROR: $_.Exception.Message"
    if ($_.Exception.Response) { $s=(New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd(); Write-Host 'BODY:'; Write-Host $s }
    exit 1
}

Write-Host "E2E comments test completed successfully."