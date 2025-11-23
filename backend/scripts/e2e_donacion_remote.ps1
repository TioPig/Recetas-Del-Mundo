<#
  scripts/e2e_donacion_remote.ps1

  Ejecuta un flujo remoto (login -> crear donación USD 333 -> verificar sesión)

  Uso:
    pwsh .\scripts\e2e_donacion_remote.ps1

  Opciones (parámetros):
    -Email (default: admin@recetas.com)
    -Password (default: cast1301)
    -Amount (en centavos, default: 33300 -> USD 333.00)
    -Currency (default: usd)
    -BaseUrl (default: http://168.181.187.137:8081)
    -AutoVerify (switch) -> llama a /donaciones/verify-session tras crear la sesión
#>

param(
    [string]$Email = "admin@recetas.com",
    [string]$Password = "cast1301",
    [int]$Amount = 33300,
    [string]$Currency = "usd",
    [string]$BaseUrl = "http://168.181.187.137:8081",
    [switch]$AutoVerify
)

function Fail($msg) { Write-Host "ERROR: $msg" -ForegroundColor Red; exit 1 }

Write-Host "E2E Remote: login -> crear donación (amount=$Amount $Currency) -> verify (if enabled)"

$loginUrl = "$BaseUrl/auth/login"
$createUrl = "$BaseUrl/donaciones/create-session"
$verifyUrl = "$BaseUrl/donaciones/verify-session"

# 1) Login
$loginBody = @{ email = $Email; password = $Password } | ConvertTo-Json
try {
    $loginResp = Invoke-RestMethod -Method Post -Uri $loginUrl -Body $loginBody -ContentType 'application/json' -ErrorAction Stop
} catch {
    Fail "Login request failed: $($_.Exception.Message)"
}

if (-not $loginResp.token) { Fail "No se recibió token en la respuesta de login: $(ConvertTo-Json $loginResp)" }
$token = $loginResp.token
Write-Host "Token obtenido. Usuario: $($loginResp.usuario.correo) Id: $($loginResp.usuario.id_usr)"

# 2) Crear sesión de donación
Write-Host "Creando sesión de donación..."
$body = @{ amount = $Amount; currency = $Currency; idReceta = $null } | ConvertTo-Json
try {
    $createResp = Invoke-RestMethod -Method Post -Uri $createUrl -Body $body -ContentType 'application/json' -Headers @{ Authorization = "Bearer $token" } -ErrorAction Stop
} catch {
    $respCode = ''
    try { if ($_.Exception.Response -ne $null) { $respCode = $_.Exception.Response.StatusCode.Value__ } } catch { }
    Fail ("create-session failed: " + $_.Exception.Message + "`nResponse: " + $respCode)
}

Write-Host "create-session response:`n" -ForegroundColor Cyan
Write-Host (ConvertTo-Json $createResp -Depth 6)

$sessionId = $null
if ($createResp.sessionId) { $sessionId = $createResp.sessionId }
elseif ($createResp.sesion_pago -and $createResp.sesion_pago.sessionId) { $sessionId = $createResp.sesion_pago.sessionId }
elseif ($createResp.sesion_pago -and $createResp.sesion_pago.session_id) { $sessionId = $createResp.sesion_pago.session_id }

if ($sessionId) { Write-Host "SessionId: $sessionId" -ForegroundColor Green }
if ($createResp.url) { Write-Host "Checkout URL: $($createResp.url)" -ForegroundColor Green }

# 3) Verify-session (opcional o automático)
if ($AutoVerify -or $true) {
    if (-not $sessionId) { Write-Host "No sessionId encontrado para verificar. Omite verify-session." -ForegroundColor Yellow }
    else {
        Write-Host "Llamando /donaciones/verify-session para sessionId: $sessionId"
        $vbody = @{ sessionId = $sessionId } | ConvertTo-Json
        try {
            $verifyResp = Invoke-RestMethod -Method Post -Uri $verifyUrl -Body $vbody -ContentType 'application/json' -Headers @{ Authorization = "Bearer $token" } -ErrorAction Stop
            Write-Host "verify-session response:`n" -ForegroundColor Cyan
            Write-Host (ConvertTo-Json $verifyResp -Depth 6)
        } catch {
            Write-Host "verify-session failed: $($_.Exception.Message)" -ForegroundColor Yellow
            try { Write-Host ($_ | ConvertTo-Json -Depth 6) } catch { }
        }
    }
}

Write-Host "E2E remoto terminado. Revisa la DB remota o el panel para confirmar estado de donación." -ForegroundColor Magenta
<# DEPRECATED: original script preserved in scripts/deprecated/e2e_donacion_remote.ps1 #>
Write-Host 'This file has been deprecated and the original preserved in scripts/deprecated/e2e_donacion_remote.ps1'
