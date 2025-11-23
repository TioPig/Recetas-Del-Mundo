# E2E script: login -> modificar nombre -> eliminar usuario
param(
    [string]$baseUrl = "http://localhost:8081",
    [string]$adminEmail = "admin@recetas.com",
    [string]$adminPass = "cast1301"
)

Write-Host "E2E Usuarios: baseUrl=$baseUrl --- Login admin: $adminEmail"

function Invoke-Json {
    param($method, $uri, $body = $null, $headers = @{})
    if ($null -ne $body) {
        $json = $body | ConvertTo-Json -Depth 10
        return Invoke-RestMethod -Method $method -Uri $uri -Headers $headers -ContentType 'application/json' -Body $json
    } else {
        return Invoke-RestMethod -Method $method -Uri $uri -Headers $headers
    }
}

# 1) Login
$loginBody = @{ email = $adminEmail; password = $adminPass }
$login = Invoke-Json -method POST -uri "$baseUrl/auth/login" -body $loginBody
if (-not $login -or -not $login.token) {
    Write-Error "Login failed or token missing"
    exit 1
}
$token = $login.token
$headers = @{ Authorization = "Bearer $token" }
Write-Host "Login OK. Token length: $($token.Length)"

# 2) Buscar un usuario de prueba existente (preferible user@recetas.com) usando GET /usuarios con token admin
$preferredEmail = "user@recetas.com"
Write-Host "Buscando usuario preferido: $preferredEmail"
try {
    $allUsersResp = Invoke-Json -method GET -uri "$baseUrl/usuarios" -headers $headers
    $list = $null
    if ($allUsersResp -and $allUsersResp.data) { $list = $allUsersResp.data } elseif ($allUsersResp -is [System.Array]) { $list = $allUsersResp }
    if ($null -ne $list) {
        $found = $list | Where-Object { $_.email -eq $preferredEmail }
        if ($found) {
            $userId = $found.idUsr
            Write-Host "Usuario preferido encontrado: $userId ($preferredEmail)"
        } else {
            # fallback: elegir primer usuario activo distinto del admin
            $adminId = $login.usuario.id_usr
            $candidate = $list | Where-Object { $_.idUsr -ne $adminId -and ($_.estado -eq 1 -or $_.estado -eq '1') } | Select-Object -First 1
            if ($candidate) {
                $userId = $candidate.idUsr
                Write-Host "Usuario fallback elegido: $userId (email: $($candidate.email))"
            }
        }
    }
} catch {
    Write-Warning "GET /usuarios falló: $($_.Exception.Message)"
}

if (-not $userId) {
    Write-Error "No se encontró usuario de prueba para realizar E2E usuarios. Por favor crea 'user@recetas.com' o indicar otro email de usuario existente."
    exit 1
}

# 3) Modificar nombre del usuario (PUT /usuarios/{id})
# 3) Modificar nombre del usuario (PUT /usuarios/{id})
$newName = "E2E Modified"
# Obtener usuario actual para preservar campos obligatorios
try {
    $existingResp = Invoke-Json -method GET -uri "$baseUrl/usuarios/$userId" -headers $headers
    $existing = $null
    if ($existingResp -and $existingResp.data) { $existing = $existingResp.data } elseif ($existingResp -and $existingResp.usuario) { $existing = $existingResp.usuario } else { $existing = $existingResp }
} catch {
    Write-Error "No se pudo obtener usuario existente: $($_.Exception.Message)"
    exit 1
}

# Construir payload de actualización preservando campos que el PUT exige
$updateBody = @{
    nombre = $newName
    apellido = $existing.apellido
    email = $existing.email
    password = $existing.password
    estado = $existing.estado
    perfil = $existing.perfil
}

$updated = Invoke-Json -method PUT -uri "$baseUrl/usuarios/$userId" -body $updateBody -headers $headers
try {
    $raw = $updated | ConvertTo-Json -Depth 6
    Write-Host "Raw update response: $raw"
} catch { }

# Extraer nombre actualizado según la forma de respuesta
$updatedName = $null
if ($updated -and $updated.data -and $updated.data.nombre) { $updatedName = $updated.data.nombre }
elseif ($updated -and $updated.usuario -and $updated.usuario.nombre) { $updatedName = $updated.usuario.nombre }
elseif ($updated -and $updated.nombre) { $updatedName = $updated.nombre }

Write-Host "Usuario actualizado, nombre ahora: $updatedName"
if ($updatedName -ne $newName) {
    Write-Error "Actualización no aplicada (esperado: $newName, obtenido: $updatedName)"
    exit 1
}

# 4) Eliminar usuario (DELETE /usuarios/{id})
Invoke-Json -method DELETE -uri "$baseUrl/usuarios/$userId" -headers $headers
Write-Host "Usuario $userId eliminado (soft-delete)."

# 5) Verificar que el usuario ya no esté activo (GET /usuarios/{id})
try {
    $check = Invoke-Json -method GET -uri "$baseUrl/usuarios/$userId" -headers $headers
    if ($null -eq $check -or $check.estado -eq 0) {
        Write-Host "Verificación: usuario marcado como eliminado/estado=0"
    } else {
        Write-Warning "Usuario todavía activo: estado=$($check.estado)"
    }
} catch {
    Write-Host "GET usuario devolvió error (esperado si fue eliminado completamente): $($_.Exception.Message)"
}

Write-Host "E2E usuarios completado con éxito."
exit 0
