# Clean, tested E2E script (fixed copy). Use this instead of corrupted e2e_automated.ps1.
param(
    [int]$AmountCents = 4400,
    [switch]$Interactive,
    [switch]$SimulateWebhook = $false,
    [switch]$ExportCsv = $false,
    [switch]$CheckDb = $false,
    [switch]$ForceLocal = $false
)

Set-StrictMode -Version Latest

$base = 'http://localhost:8081'
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-ErrorAndExit([string]$msg) {
    Write-Host $msg -ForegroundColor Red
    exit 1
}

function Try-Login {
    $body = @{ email = 'admin@recetas.com'; password = 'cast1301' } | ConvertTo-Json
    try {
        $r = Invoke-RestMethod -Method Post -Uri "$base/auth/login" -Body $body -ContentType 'application/json' -ErrorAction Stop
        if (-not $r.token) { Write-ErrorAndExit 'Login did not return token.' }
        Write-Host "Login OK. Token length: $($r.token.Length)"
        return $r.token
    } catch {
        Write-Host 'Login failed:' $_.Exception.Message -ForegroundColor Red
        if ($_.Exception.Response) { try { $sr = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream()); Write-Host $sr.ReadToEnd() } catch {} }
        exit 1
    }
}

function Create-Session($token, $amount) {
    $headers = @{ Authorization = "Bearer $token" }
    if ($ForceLocal) { $headers['X-Force-Local'] = '1' }
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

function Simulate-Stripe-Webhook($sessionId, $amount) {
    if (-not $env:STRIPE_WEBHOOK_SECRET) { Write-Host 'No STRIPE_WEBHOOK_SECRET in env; skipping webhook simulation' -ForegroundColor Yellow; return }
    $secret = $env:STRIPE_WEBHOOK_SECRET
    $event = @{ id = 'evt_test'; type = 'checkout.session.completed'; data = @{ object = @{ id = $sessionId; payment_status = 'paid'; amount_total = $amount; currency = 'usd' } } }
    $payload = ConvertTo-Json $event -Depth 10
    $ts = [int][double]::Parse((Get-Date -UFormat %s))
    $signed = "$ts.$payload"
    $h = New-Object System.Security.Cryptography.HMACSHA256([Text.Encoding]::UTF8.GetBytes($secret))
    $sig = ($h.ComputeHash([Text.Encoding]::UTF8.GetBytes($signed)) | ForEach-Object { $_.ToString('x2') }) -join ''
    $header = "t=$ts,v1=$sig"
    try {
        $resp = Invoke-RestMethod -Method Post -Uri "$base/webhook/stripe" -Body $payload -ContentType 'application/json' -Headers @{ 'Stripe-Signature' = $header } -ErrorAction Stop
        Write-Host 'Webhook posted, response:' (ConvertTo-Json $resp -Depth 3)
        return $resp
    } catch {
        Write-Host 'Webhook failed:' $_.Exception.Message -ForegroundColor Red
        if ($_.Exception.Response) { try { $sr = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream()); Write-Host $sr.ReadToEnd() } catch {} }
        return $null
    }
}

function Verify-Session($token, $sessionId) {
    $headers = @{ Authorization = "Bearer $token" }
    $body = @{ sessionId = $sessionId } | ConvertTo-Json
    try {
        $r = Invoke-RestMethod -Method Post -Uri "$base/donaciones/verify-session" -Headers $headers -Body $body -ContentType 'application/json' -ErrorAction Stop
        Write-Host 'Verify-session response:'
        Write-Host (ConvertTo-Json $r -Depth 6)
        return $r
    } catch {
        Write-Host 'verify-session failed:' $_.Exception.Message -ForegroundColor Red
        if ($_.Exception.Response) { try { $sr = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream()); Write-Host $sr.ReadToEnd() } catch {} }
        return $null
    }
}

function Check-Db-For-Session($sessionId) {
    $container = 'api-recetas-postgres'
    $query = "SELECT d.iddonacion, d.amount, s.sessionid, s.status FROM donacion d JOIN sesion_pago s ON s.iddonacion = d.iddonacion WHERE s.sessionid = '$sessionId';"
    try {
        $docker = Get-Command docker -ErrorAction SilentlyContinue
        if (-not $docker) { Write-Host 'Docker not available on PATH; skipping DB check' -ForegroundColor Yellow; return }
        Write-Host 'Running DB check via docker exec (may require container name to match)'
        $args = @('exec','-i',$container,'psql','-U','postgres','-d','recetas','-c',$query)
        $proc = Start-Process -FilePath 'docker' -ArgumentList $args -NoNewWindow -Wait -PassThru
        Write-Host "DB check exit code: $($proc.ExitCode)"
    } catch {
        Write-Host 'DB check failed:' $_.Exception.Message -ForegroundColor Yellow
    }
}

function Export-To-Csv($obj, $path) {
    try {
        $obj | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $path -Encoding UTF8
        Write-Host "Exported to $path"
    } catch {
        Write-Host 'Export failed:' $_.Exception.Message -ForegroundColor Yellow
    }
}

Write-Host "E2E Automated (fixed): amount(cents)=$AmountCents, Interactive=$Interactive, SimulateWebhook=$SimulateWebhook, ExportCsv=$ExportCsv, CheckDb=$CheckDb, ForceLocal=$ForceLocal"

$token = Try-Login
$createResp = Create-Session $token $AmountCents

$sessionId = $null
if ($createResp -is [System.String]) { $sessionId = $createResp } elseif ($createResp.sessionId) { $sessionId = $createResp.sessionId }
if (-not $sessionId -and $createResp.sesion_pago -and $createResp.sesion_pago.sessionId) { $sessionId = $createResp.sesion_pago.sessionId }
if (-not $sessionId) { Write-ErrorAndExit 'No sessionId returned by create-session.' }

Write-Host "SessionId: $sessionId"

if ($Interactive) {
    if ($createResp.url) {
        Write-Host 'Opening Checkout URL in default browser...'
        try { Start-Process $createResp.url } catch { Write-Host 'Failed to open browser; URL:' $createResp.url }
    } else { Write-Host 'No URL returned to open.' }
}

if ($SimulateWebhook) { Simulate-Stripe-Webhook $sessionId $AmountCents }

$verifyResp = Verify-Session $token $sessionId

if ($ExportCsv) {
    $out = @{ sessionId = $sessionId; createResponse = $createResp; verifyResponse = $verifyResp }
    $outPath = Join-Path $PSScriptRoot ("e2e_result_$((Get-Date).ToString('yyyyMMdd_HHmmss')).csv")
    Export-To-Csv $out $outPath
}

if ($CheckDb) { Check-Db-For-Session $sessionId }

Write-Host 'E2E automated (fixed) script finished.'
param(
    [int]$AmountCents = 4400,
    [switch]$Interactive,
    [switch]$SimulateWebhook = $true,
    [switch]$ExportCsv
)

function Read-EnvFile($path) {
    if (-Not (Test-Path $path)) { return @{} }
    $lines = Get-Content $path | Where-Object { $_ -and ($_ -match '^\s*[^#]') }
    $h = @{}
    foreach ($l in $lines) {
        $parts = $l -split '=',2
        if ($parts.Length -eq 2) {
            $k = $parts[0].Trim()
            $v = $parts[1].Trim().Trim("'\"")
            $h[$k] = $v
        }
    }
    return $h
}

$base = 'http://localhost:8081'
$envPath = Join-Path (Split-Path $PSScriptRoot) '..\.env' | Resolve-Path -ErrorAction SilentlyContinue
$envVars = @{}
if ($envPath) { $envVars = Read-EnvFile($envPath) }

function Get-WebHookSecret() {
    if ($env:STRIPE_WEBHOOK_SECRET) { return $env:STRIPE_WEBHOOK_SECRET }
    if ($envVars.ContainsKey('STRIPE_WEBHOOK_SECRET')) { return $envVars['STRIPE_WEBHOOK_SECRET'] }
    return $null
}

function Login($email,$password) {
    $body = @{ email = $email; password = $password } | ConvertTo-Json
    $r = Invoke-RestMethod -Method Post -Uri "$base/auth/login" -Body $body -ContentType 'application/json' -ErrorAction Stop
    return $r.token
}

function Create-Session($token,$amount) {
    $headers = @{ Authorization = "Bearer $token" }
    $body = @{ amount = $amount; currency = 'usd'; idReceta = $null } | ConvertTo-Json
    $r = Invoke-RestMethod -Method Post -Uri "$base/donaciones/create-session" -Headers $headers -Body $body -ContentType 'application/json' -ErrorAction Stop
    return $r
}

function Compute-StripeSignature($secret, $payload) {
    $ts = [int][double]::Parse((Get-Date -UFormat %s))
    $signed = "$ts.$payload"
    $h = New-Object System.Security.Cryptography.HMACSHA256([Text.Encoding]::UTF8.GetBytes($secret))
    $sig = ($h.ComputeHash([Text.Encoding]::UTF8.GetBytes($signed)) | ForEach-Object { $_.ToString('x2') }) -join ''
    return "t=$ts,v1=$sig"
}

function Send-Webhook($secret, $sessionId, $donacionId) {
    $event = @{ id = 'evt_test_e2e'; object = 'event'; api_version = '2023-08-16'; type = 'checkout.session.completed'; data = @{ object = @{ id = $sessionId; object = 'checkout.session'; payment_status = 'paid'; payment_intent = $null; amount_total = $AmountCents; currency = 'usd'; metadata = @{ donacion_id = [string]$donacionId } } } }
    $payload = (ConvertTo-Json $event -Depth 10 -Compress)
    $sig = Compute-StripeSignature $secret $payload
    $headers = @{ 'Stripe-Signature' = $sig; 'Content-Type' = 'application/json' }
    Write-Host "Sending webhook to $base/webhook/stripe"
    $resp = Invoke-RestMethod -Method Post -Uri "$base/webhook/stripe" -Body $payload -Headers $headers -ContentType 'application/json' -ErrorAction Stop
    return $resp
}

function Verify-Session($token,$sessionId) {
    $headers = @{ Authorization = "Bearer $token" }
    $body = @{ sessionId = $sessionId } | ConvertTo-Json
    $r = Invoke-RestMethod -Method Post -Uri "$base/donaciones/verify-session" -Headers $headers -Body $body -ContentType 'application/json' -ErrorAction Stop
    return $r
}

function Query-DB($donacionId, $sessionId) {
    Write-Host "Querying DB for donacion id $donacionId and session $sessionId"
    docker exec -i api-recetas-postgres psql -U postgres -d api_recetas_postgres -c "SELECT id_donacion,id_usr,amount,currency,status,stripe_payment_intent,stripe_session_id,fecha_creacion,fecha_actualizacion FROM donacion WHERE id_donacion=$donacionId;"
    docker exec -i api-recetas-postgres psql -U postgres -d api_recetas_postgres -c "SELECT id_sesion,session_id,provider,status,id_donacion,metadata,fecha_creacion,fecha_actualizacion FROM sesion_pago WHERE session_id='$sessionId';"
}

try {
    $token = Login 'admin@recetas.com' 'cast1301'
    Write-Host "Logged in, token length: $($token.Length)"

    $create = Create-Session $token $AmountCents
    Write-Host "Create response:`n" (ConvertTo-Json $create -Depth 6)

    $sessionId = $null
    if ($create.sessionId) { $sessionId = $create.sessionId } elseif ($create.sesion_pago -and $create.sesion_pago.sessionId) { $sessionId = $create.sesion_pago.sessionId }
    $donacionId = $null
    if ($create.donacion -and $create.donacion.idDonacion) { $donacionId = $create.donacion.idDonacion }

    if (-not $sessionId) { throw 'No sessionId returned' }

    if ($Interactive) {
        $url = $create.url
        if ($url) { Start-Process $url }
        else { Write-Host 'No url to open (maybe local session)'; }
        Write-Host 'Please complete Checkout in browser and then press Enter to continue...'
        Read-Host
    }

    if ($SimulateWebhook) {
        $secret = Get-WebHookSecret
        if (-not $secret) { Write-Host 'STRIPE_WEBHOOK_SECRET not found in env or .env; cannot sign webhook. Aborting simulation.' -ForegroundColor Yellow }
        else {
            Write-Host 'Simulating webhook (checkout.session.completed) ...'
            $resp = Send-Webhook $secret $sessionId $donacionId
            Write-Host 'Webhook response:' (ConvertTo-Json $resp -Depth 4)
        }
    }

    Write-Host 'Calling verify-session...'
    $verify = Verify-Session $token $sessionId
    Write-Host 'Verify response:' (ConvertTo-Json $verify -Depth 8)

    Query-DB $donacionId $sessionId

    if ($ExportCsv) {
        Write-Host 'Exporting rows to CSV: donations_export.csv and sessions_export.csv'
        docker exec -i api-recetas-postgres psql -U postgres -d api_recetas_postgres -c "COPY (SELECT * FROM donacion WHERE id_donacion=$donacionId) TO STDOUT WITH CSV HEADER" > donations_export.csv
        docker exec -i api-recetas-postgres psql -U postgres -d api_recetas_postgres -c "COPY (SELECT * FROM sesion_pago WHERE session_id='$sessionId') TO STDOUT WITH CSV HEADER" > sessions_export.csv
        Write-Host 'Export complete.'
    }

    Write-Host 'E2E automated flow complete.'
} catch {
    Write-Host 'ERROR:' $_.Exception.Message -ForegroundColor Red
    if ($_.Exception.Response) { try { $sr = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream()); $txt = $sr.ReadToEnd(); Write-Host 'Response body:'; Write-Host $txt } catch {} }
    exit 1
}
