param(
    [int]$AmountCents = 4400,
    [switch]$Interactive,
    [switch]$SimulateWebhook = $false,
    [switch]$ForceLocal = $false
)

$base = 'http://localhost:8081'

function Try-Login {
    $body = @{ email = 'admin@recetas.com'; password = 'cast1301' } | ConvertTo-Json
    $r = Invoke-RestMethod -Method Post -Uri "$base/auth/login" -Body $body -ContentType 'application/json'
    return $r.token
}

function Create-Session($token,$amount) {
    $headers = @{ Authorization = "Bearer $token" }
    if ($ForceLocal) { $headers['X-Force-Local'] = '1' }
    $body = @{ amount = $amount; currency = 'usd'; idReceta = $null } | ConvertTo-Json
    $r = Invoke-RestMethod -Method Post -Uri "$base/donaciones/create-session" -Headers $headers -Body $body -ContentType 'application/json'
    return $r
}

function Simulate-Webhook($sessionId) {
    if (-not $env:STRIPE_WEBHOOK_SECRET) { Write-Host 'No STRIPE_WEBHOOK_SECRET in env; skipping webhook simulation' -ForegroundColor Yellow; return }
    $secret = $env:STRIPE_WEBHOOK_SECRET
    $event = @{ id = 'evt_test'; type = 'checkout.session.completed'; data = @{ object = @{ id = $sessionId; payment_status = 'paid'; amount_total = $AmountCents; currency = 'usd' } } }
    $payload = ConvertTo-Json $event -Depth 10
    $ts = [int][double]::Parse((Get-Date -UFormat %s))
    $signed = "$ts.$payload"
    $keyBytes = [Text.Encoding]::UTF8.GetBytes($secret)
    $h = New-Object System.Security.Cryptography.HMACSHA256 -ArgumentList (,@($keyBytes))
    $sig = ($h.ComputeHash([Text.Encoding]::UTF8.GetBytes($signed)) | ForEach-Object { $_.ToString('x2') }) -join ''
    $header = "t=$ts,v1=$sig"
    try {
        $resp = Invoke-RestMethod -Method Post -Uri "$base/webhook/stripe" -Body $payload -ContentType 'application/json' -Headers @{ 'Stripe-Signature' = $header } -ErrorAction Stop
        Write-Host 'Webhook posted.'
    } catch {
        Write-Host 'Webhook failed:' $_.Exception.Message -ForegroundColor Red
    }
}

Write-Host 'Running E2E clean script...'
$token = Try-Login
$create = Create-Session $token $AmountCents
Write-Host 'Create-session response:'
Write-Host (ConvertTo-Json $create -Depth 6)

$sessionId = $null
if ($create.sessionId) { $sessionId = $create.sessionId } elseif ($create.sesion_pago -and $create.sesion_pago.sessionId) { $sessionId = $create.sesion_pago.sessionId }
if (-not $sessionId) { Write-Host 'No sessionId returned' -ForegroundColor Red; exit 1 }
Write-Host 'SessionId:' $sessionId

if ($Interactive -and $create.url) { Start-Process $create.url }
if ($SimulateWebhook) { Simulate-Webhook $sessionId }

Write-Host 'E2E clean script finished.'
