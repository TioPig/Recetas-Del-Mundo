#!/usr/bin/env pwsh
# Test manual de favoritos: registra usuario, obtiene token, escoge una receta y realiza add/list/delete/list
param(
    [string]$base = $(if ($env:E2E_BASE_URL) { $env:E2E_BASE_URL } else { 'http://localhost:8081' })
)

function ExitWithBodyError($ex) {
    Write-Host $ex.Exception.Message
    if ($ex.Exception.Response) {
        $s = (New-Object System.IO.StreamReader($ex.Exception.Response.GetResponseStream())).ReadToEnd()
        Write-Host 'BODY:'; Write-Host $s
    }
    exit 1
}

$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$email = "test.favoritos.$ts@example.com"
$password = "P@ssw0rd123"
$name = "TestFav"

$regBody = @{ nombre = $name; apellido = 'UserFav'; email = $email; password = $password } | ConvertTo-Json

Write-Host "Registering user: $email"
try {
    $reg = Invoke-RestMethod -Uri "$base/auth/register" -Method Post -ContentType 'application/json' -Body $regBody -ErrorAction Stop
    Write-Host 'REGISTER_RESPONSE:'; $reg | ConvertTo-Json -Depth 6 | Write-Host
} catch {
    ExitWithBodyError($_)
}

# Login
$loginBody = @{ email = $email; password = $password } | ConvertTo-Json
Write-Host "Logging in to obtain JWT"
try {
    $login = Invoke-RestMethod -Uri "$base/auth/login" -Method Post -ContentType 'application/json' -Body $loginBody -ErrorAction Stop
    Write-Host 'LOGIN_RESPONSE:'; $login | ConvertTo-Json -Depth 6 | Write-Host
} catch {
    ExitWithBodyError($_)
}

# Extract token from common shapes
$token = $null
if ($login -is [string]) { $token = $login }
elseif ($login.token) { $token = $login.token }
elseif ($login.data -and $login.data.token) { $token = $login.data.token }
elseif ($login.access_token) { $token = $login.access_token }
elseif ($login.jwt) { $token = $login.jwt }

if (-not $token) {
    Write-Host 'No token found in login response'; exit 1
}

$headers = @{ Authorization = "Bearer $token" }
Write-Host "Using token: $(if ($token.Length -gt 20) { $token.Substring(0,20) + '...' } else { $token })"

# Pick a receta id dynamically
Write-Host 'Querying /recetas to pick one receta id'
try {
    $recResp = Invoke-RestMethod -Uri "$base/recetas" -Method Get -Headers $headers -ErrorAction Stop
} catch {
    # try without auth header if listing is public
    try { $recResp = Invoke-RestMethod -Uri "$base/recetas" -Method Get -ErrorAction Stop } catch { ExitWithBodyError($_) }
}

function Get-FirstRecetaId($r) {
    if (-not $r) { return $null }
    $item = $null
    if ($r -is [System.Array] -and $r.Length -gt 0) { $item = $r[0] }
    elseif ($r.data -and $r.data[0]) { $item = $r.data[0] }
    if (-not $item) { return $null }
    if ($null -ne $item.idReceta) { return $item.idReceta }
    if ($null -ne $item.id_receta) { return $item.id_receta }
    if ($null -ne $item.id) { return $item.id }
    return $null
}

$idReceta = Get-FirstRecetaId $recResp
if (-not $idReceta) { Write-Host 'Falling back to receta id = 8'; $idReceta = 8 }

# Try to extract user id from token payload (best-effort)
function Decode-JwtPayload($jwt) {
    $parts = $jwt -split '\.'
    if ($parts.Length -lt 2) { return $null }
    $payload = $parts[1]
    switch ($payload.Length % 4) { 2 { $payload += '==' } 3 { $payload += '=' } default { } }
    try {
        $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($payload))
        return $decoded | ConvertFrom-Json
    } catch { return $null }
}

$payload = Decode-JwtPayload $token
$idUsuario = $null
if ($login.usuario -and $login.usuario.id_usr) { $idUsuario = $login.usuario.id_usr }
elseif ($payload) {
    $idUsuario = $payload.id_usr -or $payload.idUsr -or $payload.sub
}
if (-not $idUsuario) { $idUsuario = 1 }

Write-Host "Will use idUsuario=$idUsuario idReceta=$idReceta"

# Add favorito
Write-Host "Adding favorito id_usr=$idUsuario id_receta=$idReceta"
try {
    $add = Invoke-RestMethod -Uri "$base/recetas/favoritos?id_usr=$idUsuario&id_receta=$idReceta" -Method Post -Headers $headers -ErrorAction Stop
    Write-Host 'ADD_RESPONSE:'; $add | ConvertTo-Json -Depth 6 | Write-Host
} catch { ExitWithBodyError($_) }

# List favoritos
Write-Host 'Listing favoritos (after add)'
try {
    $list = Invoke-RestMethod -Uri "$base/recetas/favoritos" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host 'LIST_RESPONSE:'; $list | ConvertTo-Json -Depth 6 | Write-Host
} catch { ExitWithBodyError($_) }

# Delete favorito
Write-Host "Deleting favorito id_usr=$idUsuario id_receta=$idReceta"
try {
    $del = Invoke-RestMethod -Uri "$base/recetas/favoritos?id_usr=$idUsuario&id_receta=$idReceta" -Method Delete -Headers $headers -ErrorAction Stop
    Write-Host 'DELETE_RESPONSE:'; $del | ConvertTo-Json -Depth 6 | Write-Host
} catch { ExitWithBodyError($_) }

# List again
Write-Host 'Listing favoritos (after delete)'
try {
    $list2 = Invoke-RestMethod -Uri "$base/recetas/favoritos" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host 'LIST2_RESPONSE:'; $list2 | ConvertTo-Json -Depth 6 | Write-Host
} catch { ExitWithBodyError($_) }

Write-Host 'E2E favoritos manual test completed.'