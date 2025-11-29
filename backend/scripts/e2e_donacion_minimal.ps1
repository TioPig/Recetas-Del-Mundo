<#
  scripts/e2e_donacion_minimal.ps1

  Prueba E2E mínima para donación:
    1) Inicia sesión en el backend (/auth/login) con email+password
    2) Extrae token JWT
    3) Crea una sesión de donación POST /donaciones/create-session (amount en cents)
    4) Muestra la respuesta (sessionId, url, donacion)
    5) (opcional) llama /donaciones/verify-session para forzar verificación

  Uso (PowerShell desde la raíz del repo):
    pwsh .\scripts\e2e_donacion_minimal.ps1 -Email 'tu@correo' -Password 'tu_pass' -Amount 10000

  Notas:
    - `Amount` en centavos (10000 = USD 100.00)
    - Ajusta `$BaseUrl` si tu backend no corre en http://localhost:8080
    - El script no realiza pagos en Stripe; si la sesión es real deberás completar el pago manualmente o reenviar webhooks con Stripe CLI.
#>

param(
    [Parameter(Mandatory=$true)] [string]$Email,
    [Parameter(Mandatory=$true)] [string]$Password,
    [int]$Amount = 10000,
    [string]$Currency = "usd",
    [string]$BaseUrl = "http://localhost:8080",
    [switch]$AutoVerify
)

function Fail($msg) { Write-Host "ERROR: $msg" -ForegroundColor Red; exit 1 }

Write-Host "E2E: login -> crear sesión donación (amount=$Amount $Currency)"

$loginUrl = "$BaseUrl/auth/login"
$createUrl = "$BaseUrl/donaciones/create-session"
$verifyUrl = "$BaseUrl/donaciones/verify-session"

Write-Host "Login en: $loginUrl"

$loginBody = @{ email = $Email; password = $Password } | ConvertTo-Json
try {
    $loginResp = Invoke-RestMethod -Method Post -Uri $loginUrl -Body $loginBody -ContentType 'application/json' -ErrorAction Stop
} catch {
    Fail "Login request failed: $($_.Exception.Message)"
}

if (-not $loginResp.token) { Fail "No se recibió token en la respuesta de login: $(ConvertTo-Json $loginResp)" }
$token = $loginResp.token
Write-Host "Token obtenido. Usuario: $($loginResp.usuario.correo) Id: $($loginResp.usuario.id_usr)"

Write-Host "Creando sesión de donación..."
$body = @{ amount = $Amount; currency = $Currency; idReceta = $null } | ConvertTo-Json
try {
    $createResp = Invoke-RestMethod -Method Post -Uri $createUrl -Body $body -ContentType 'application/json' -Headers @{ Authorization = "Bearer $token" } -ErrorAction Stop
} catch {
    $respCode = ''
    try {
        if ($_.Exception.Response -ne $null) { $respCode = $_.Exception.Response.StatusCode.Value__ }
    } catch { }
    Fail ("create-session failed: " + $_.Exception.Message + "`nResponse: " + $respCode)
}

Write-Host "create-session response:`n" -ForegroundColor Cyan
Write-Host (ConvertTo-Json $createResp -Depth 5)

$sessionId = $null
if ($createResp.sessionId) { $sessionId = $createResp.sessionId }
elseif ($createResp.sesion_pago -and $createResp.sesion_pago.sessionId) { $sessionId = $createResp.sesion_pago.sessionId }
elseif ($createResp.sesion_pago -and $createResp.sesion_pago.session_id) { $sessionId = $createResp.sesion_pago.session_id }

if ($sessionId) { Write-Host "SessionId: $sessionId" -ForegroundColor Green }
if ($createResp.url) { Write-Host "Checkout URL: $($createResp.url)" -ForegroundColor Green }

if ($AutoVerify) {
    if (-not $sessionId) { Fail "No sessionId encontrado para verificar." }
    Write-Host "AutoVerify activado: llamando /donaciones/verify-session..."
    $vbody = @{ sessionId = $sessionId } | ConvertTo-Json
    try {
        $verifyResp = Invoke-RestMethod -Method Post -Uri $verifyUrl -Body $vbody -ContentType 'application/json' -Headers @{ Authorization = "Bearer $token" } -ErrorAction Stop
        Write-Host "verify-session response:`n" -ForegroundColor Cyan
        Write-Host (ConvertTo-Json $verifyResp -Depth 5)
    } catch {
        Write-Host "verify-session failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host "E2E terminado. Revisa la DB para donacion/sesion_pago o sigue con pago en el navegador si se creó Checkout URL." -ForegroundColor Magenta
