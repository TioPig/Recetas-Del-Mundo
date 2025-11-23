# E2E script: dar y quitar Me Gusta (recetas/megusta)
param(
    [string]$base = $(if ($env:E2E_BASE_URL) { $env:E2E_BASE_URL } else { 'http://localhost:8081' }),
    [string]$email = $(if ($env:E2E_EMAIL) { $env:E2E_EMAIL } else { '<ADMIN_EMAIL>' }),
    [string]$password = $(if ($env:E2E_PASSWORD) { $env:E2E_PASSWORD } else { '<PASSWORD>' })
)

# Uso: .\e2e_megusta.ps1 -base http://localhost:8081 -email <ADMIN_EMAIL> -password <PASSWORD>
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

# Variables
$idUsuario = 1
$idReceta = 1

# Agregar me gusta
Write-Host "-> Agregando me gusta idUsuario=$idUsuario idReceta=$idReceta"
try {
    $add = Invoke-RestMethod -Uri "$base/recetas/megusta?idUsuario=$idUsuario&idReceta=$idReceta" -Method Post -Headers $headers -ErrorAction Stop
    $add | ConvertTo-Json -Depth 6 | Write-Host
} catch {
    Write-Host "ADD ERROR: $_.Exception.Message"
    if ($_.Exception.Response) { $s=(New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd(); Write-Host 'BODY:'; Write-Host $s }
    exit 1
}

# Verificar GET /recetas/megusta (contextual por token)
Write-Host "-> Obteniendo me gusta del usuario autenticado"
try {
    $list = Invoke-RestMethod -Uri "$base/recetas/megusta" -Method Get -Headers $headers -ErrorAction Stop
    $list | ConvertTo-Json -Depth 6 | Write-Host
} catch {
    Write-Host "LIST ERROR: $_.Exception.Message"
    if ($_.Exception.Response) { $s=(New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd(); Write-Host 'BODY:'; Write-Host $s }
    exit 1
}

# Quitar me gusta
Write-Host "-> Quitando me gusta idUsuario=$idUsuario idReceta=$idReceta"
try {
    $del = Invoke-RestMethod -Uri "$base/recetas/megusta?idUsuario=$idUsuario&idReceta=$idReceta" -Method Delete -Headers $headers -ErrorAction Stop
    $del | ConvertTo-Json -Depth 6 | Write-Host
} catch {
    Write-Host "DELETE ERROR: $_.Exception.Message"
    if ($_.Exception.Response) { $s=(New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd(); Write-Host 'BODY:'; Write-Host $s }
    exit 1
}

# Verificar que fue removido
Write-Host "-> Verificando me gusta tras eliminación"
try {
    $list2 = Invoke-RestMethod -Uri "$base/recetas/megusta" -Method Get -Headers $headers -ErrorAction Stop
    $list2 | ConvertTo-Json -Depth 6 | Write-Host
} catch {
    Write-Host "LIST2 ERROR: $_.Exception.Message"
    if ($_.Exception.Response) { $s=(New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd(); Write-Host 'BODY:'; Write-Host $s }
    exit 1
}

Write-Host "E2E megusta test completed."