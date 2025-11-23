# E2E interactions: me gusta, favoritos, estrellas y donacion (si aplica)
# Requisitos: backend en http://localhost:8081 y credenciales provistas vía parámetros o variables de entorno

param(
    [string]$baseUrl = $(if ($env:E2E_BASE_URL) { $env:E2E_BASE_URL } else { 'http://localhost:8081' }),
    [string]$adminEmail = $(if ($env:E2E_EMAIL) { $env:E2E_EMAIL } else { '<ADMIN_EMAIL>' }),
    [string]$adminPass = $(if ($env:E2E_PASSWORD) { $env:E2E_PASSWORD } else { '<PASSWORD>' })
)

function Get-Token {
    param($email, $password)
    $body = @{ email = $email; password = $password } | ConvertTo-Json -Depth 6
    $resp = Invoke-RestMethod -Uri 'http://localhost:8081/auth/login' -Method Post -ContentType 'application/json' -Body $body
    if ($null -ne $resp.token) { return $resp.token }
    if ($null -ne $resp.data -and $null -ne $resp.data.token) { return $resp.data.token }
    return $null
}

function Do-Request {
    param($method, $url, $headers, $bodyJson)
    try {
        if ($method -eq 'GET') { return Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ErrorAction Stop }
        if ($method -eq 'POST') { return Invoke-RestMethod -Uri $url -Method Post -Headers $headers -ContentType 'application/json' -Body $bodyJson -ErrorAction Stop }
        if ($method -eq 'DELETE') { return Invoke-RestMethod -Uri $url -Method Delete -Headers $headers -ErrorAction Stop }
        if ($method -eq 'PUT') { return Invoke-RestMethod -Uri $url -Method Put -Headers $headers -ContentType 'application/json' -Body $bodyJson -ErrorAction Stop }
    } catch {
        $respBody = $null
        try {
            if ($null -ne $_.Exception.Response) {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $respBody = $reader.ReadToEnd()
            }
        } catch { $respBody = $null }
        return @{ error = $_.ToString(); response = $respBody }
    }
}

Write-Host "Starting E2E interactions... baseUrl=$baseUrl (credential not printed)"
$token = Get-Token -email $adminEmail -password $adminPass
if (-not $token) { Write-Host 'No token obtained. Abort.'; exit 1 }
$h = @{ Authorization = "Bearer $token" }

# Choose test usuario and receta ids (ajustar si necesitas otros)
$usuarioId = 1
$recetaId = 1

# 1) Me Gusta: POST then DELETE
Write-Host "\n== Me Gusta: crear -> borrar =="
$postMg = Do-Request -method 'POST' -url "$baseUrl/recetas/megusta?id_usr=$usuarioId&id_receta=$recetaId" -headers $h -bodyJson $null
Write-Host "POST /recetas/megusta response:"; $postMg | ConvertTo-Json -Depth 5

$delMg = Do-Request -method 'DELETE' -url "$baseUrl/recetas/megusta?id_usr=$usuarioId&id_receta=$recetaId" -headers $h -bodyJson $null
Write-Host "DELETE /recetas/megusta response:"; $delMg | ConvertTo-Json -Depth 5

# 2) Favorito: POST then DELETE
Write-Host "\n== Favorito: crear -> borrar =="
$postFav = Do-Request -method 'POST' -url "$baseUrl/recetas/favoritos?id_usr=$usuarioId&id_receta=$recetaId" -headers $h -bodyJson $null
Write-Host "POST /recetas/favoritos response:"; $postFav | ConvertTo-Json -Depth 5

$delFav = Do-Request -method 'DELETE' -url "$baseUrl/recetas/favoritos?id_usr=$usuarioId&id_receta=$recetaId" -headers $h -bodyJson $null
Write-Host "DELETE /recetas/favoritos response:"; $delFav | ConvertTo-Json -Depth 5

# 3) Estrella: POST (crear/update) and PUT (update)
Write-Host "\n== Estrella: crear -> actualizar =="
$postEst = Do-Request -method 'POST' -url "$baseUrl/recetas/estrellas?id_usr=$usuarioId&id_receta=$recetaId&estrellas=4" -headers $h -bodyJson $null
Write-Host "POST /recetas/estrellas response:"; $postEst | ConvertTo-Json -Depth 5

Write-Host "(No se hara PUT de actualizacion para estrellas - no requerido)"

# 4) Donacion: intentar crear registro (si endpoint disponible)
Write-Host "\n== Donacion: intentar crear sesión/registro =="
# Buscar endpoints comunes: /donaciones/create-session, /donaciones, /recetas/donacion
$donationEndpoints = @('http://localhost:8081/donaciones/create-session','http://localhost:8081/donaciones','http://localhost:8081/recetas/donacion','http://localhost:8081/donaciones/create-session/stripe')
$donResp = $null
foreach ($ep in $donationEndpoints) {
    Write-Host "Probando endpoint: $ep"
    $payload = @{ idUsr = $usuarioId; idReceta = $recetaId; amount = 1000 } | ConvertTo-Json -Depth 6
    $res = Do-Request -method 'POST' -url $ep -headers $h -bodyJson $payload
    if ($res -is [System.Collections.Hashtable] -and $res.error) { Write-Host "No disponible o error: " $res.error; continue } else { $donResp = $res; break }
}
if ($donResp) { Write-Host "Donacion response:"; $donResp | ConvertTo-Json -Depth 6 } else { Write-Host "No se pudo crear donacion o no existe endpoint público probado." }

Write-Host "\nE2E interactions finished."