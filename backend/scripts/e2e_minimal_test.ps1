param(
    [int]$AmountCents = 4400,
    [switch]$SimulateWebhook = $true
)

$base = 'http://localhost:8081'

function Try-Login {
    $body = @{ email = 'admin@recetas.com'; password = 'cast1301' } | ConvertTo-Json
    try {
        $r = Invoke-RestMethod -Method Post -Uri "$base/auth/login" -Body $body -ContentType 'application/json' -ErrorAction Stop
        Write-Host 'Login OK. Token length:' ($r.token.Length)
        return $r.token
    } catch {
        Write-Host 'Login failed:' $_.Exception.Message -ForegroundColor Red
        if ($_.Exception.Response) { try { $sr = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream()); Write-Host $sr.ReadToEnd() } catch {} }
        exit 1
    }
}

function Create-Session($token,$amount) {
    $headers = @{ Authorization = "Bearer $token" }
    $body = @{ amount = $amount; currency = 'usd'; idReceta = $null } | ConvertTo-Json
    try {
        $r = Invoke-RestMethod -Method Post -Uri "$base/donaciones/create-session" -Headers $headers -Body $body -ContentType 'application/json' -ErrorAction Stop
        Write-Host 'Create-session response:'
        Write-Host (ConvertTo-Json $r -Depth 6)
        return $r
    } catch {
        Write-Host 'create-session failed:' $_.Exception.Message -ForegroundColor Red
        if ($_.Exception.Response) { try { $sr = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream()); Write-Host $sr.ReadToEnd() } catch {} }
        exit 1
    }
}

function Simulate-Webhook($sessionId) {
    if (-not $env:STRIPE_WEBHOOK_SECRET) { Write-Host 'No STRIPE_WEBHOOK_SECRET in env; skipping webhook simulation' -ForegroundColor Yellow; return }
    $secret = $env:STRIPE_WEBHOOK_SECRET
    $event = @{ id = 'evt_test'; type = 'checkout.session.completed'; data = @{ object = @{ id = $sessionId; payment_status = 'paid'; amount_total = $AmountCents; currency = 'usd' } } }
    $payload = ConvertTo-Json $event -Depth 10
    $ts = [int][double]::Parse((Get-Date -UFormat %s))
    $signed = "$ts.$payload"
    $h = New-Object System.Security.Cryptography.HMACSHA256([Text.Encoding]::UTF8.GetBytes($secret))
    $sig = ($h.ComputeHash([Text.Encoding]::UTF8.GetBytes($signed)) | ForEach-Object { $_.ToString('x2') }) -join ''
    $header = "t=$ts,v1=$sig"
    try {
        $resp = Invoke-RestMethod -Method Post -Uri "$base/webhook/stripe" -Body $payload -ContentType 'application/json' -Headers @{ 'Stripe-Signature' = $header } -ErrorAction Stop
        Write-Host 'Webhook posted, response:' (ConvertTo-Json $resp -Depth 3)
    } catch {
        Write-Host 'Webhook failed:' $_.Exception.Message -ForegroundColor Red
        if ($_.Exception.Response) { try { $sr = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream()); Write-Host $sr.ReadToEnd() } catch {} }
    }
}

Write-Host 'Running minimal E2E test...'
$token = Try-Login
$createResp = Create-Session $token $AmountCents
$sessionId = $null
if ($createResp.sessionId) { $sessionId = $createResp.sessionId } elseif ($createResp.sesion_pago -and $createResp.sesion_pago.sessionId) { $sessionId = $createResp.sesion_pago.sessionId }
if (-not $sessionId) { Write-Host 'No sessionId returned' -ForegroundColor Red; exit 1 }
Write-Host 'SessionId:' $sessionId
if ($SimulateWebhook) { Simulate-Webhook $sessionId }
Write-Host 'Minimal E2E done.'
