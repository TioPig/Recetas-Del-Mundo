# E2E script: agregar y quitar una receta de favoritos
param(
    [string]$base = $(if ($env:E2E_BASE_URL) { $env:E2E_BASE_URL } else { 'http://localhost:8081' }),
    [string]$email = $(if ($env:E2E_EMAIL) { $env:E2E_EMAIL } else { '<ADMIN_EMAIL>' }),
    [string]$password = $(if ($env:E2E_PASSWORD) { $env:E2E_PASSWORD } else { '<PASSWORD>' })
)

# Uso: .\e2e_favoritos.ps1 -base http://localhost:8081 -email <ADMIN_EMAIL> -password <PASSWORD>
$creds = @{ email = $email; password = $password } | ConvertTo-Json

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

$token = Get-Token -email $email -password $password
$headers = @{ Authorization = "Bearer $token" }

# Agregar favorito
$idUsuario = 1
$idReceta = 1
Write-Host "-> Agregando favorito idUsuario=$idUsuario idReceta=$idReceta"
try {
    $add = Invoke-RestMethod -Uri "$base/recetas/favoritos?id_usr=$idUsuario&id_receta=$idReceta" -Method Post -Headers $headers -ErrorAction Stop
    $add | ConvertTo-Json -Depth 6 | Write-Host
} catch {
    Write-Host "ADD ERROR: $_.Exception.Message"
    if ($_.Exception.Response) { $s=(New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd(); Write-Host 'BODY:'; Write-Host $s }
    exit 1
}

# Verificar en GET /recetas/favoritos (consulta contextual por token)
Write-Host "-> Obteniendo favoritos del usuario autenticado"
try {
    $list = Invoke-RestMethod -Uri "$base/recetas/favoritos" -Method Get -Headers $headers -ErrorAction Stop
    $list | ConvertTo-Json -Depth 6 | Write-Host
} catch {
    Write-Host "LIST ERROR: $_.Exception.Message"
    if ($_.Exception.Response) { $s=(New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd(); Write-Host 'BODY:'; Write-Host $s }
    exit 1
}

# Quitar favorito
Write-Host "-> Quitando favorito idUsuario=$idUsuario idReceta=$idReceta"
try {
    $del = Invoke-RestMethod -Uri "$base/recetas/favoritos?id_usr=$idUsuario&id_receta=$idReceta" -Method Delete -Headers $headers -ErrorAction Stop
    $del | ConvertTo-Json -Depth 6 | Write-Host
} catch {
    Write-Host "DELETE ERROR: $_.Exception.Message"
    if ($_.Exception.Response) { $s=(New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd(); Write-Host 'BODY:'; Write-Host $s }
    exit 1
}

# Verificar que ya no está
Write-Host "-> Verificando favoritos de usuario tras eliminación"
try {
    $list2 = Invoke-RestMethod -Uri "$base/recetas/favoritos" -Method Get -Headers $headers -ErrorAction Stop
    $list2 | ConvertTo-Json -Depth 6 | Write-Host
} catch {
    Write-Host "LIST2 ERROR: $_.Exception.Message"
    if ($_.Exception.Response) { $s=(New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd(); Write-Host 'BODY:'; Write-Host $s }
    exit 1
}

Write-Host "E2E favoritos test completed."