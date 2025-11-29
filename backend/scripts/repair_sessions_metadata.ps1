<#
Repair missing metadata for sesion_pago by fetching Checkout Session from Stripe
Requirements: .env must contain STRIPE_SECRET_KEY and DB must be reachable in docker container
#>
param(
    [switch]$DryRun
)

Write-Host "Loading .env..."
if (Test-Path ".env") {
    Get-Content ".env" | ForEach-Object { if ($_ -match '^\s*([^#\s][^=]*)=(.*)$') { $k=$matches[1].Trim(); $v=$matches[2].Trim(); [System.Environment]::SetEnvironmentVariable($k,$v,'Process') } }
} else {
    Write-Host "No .env in repo root; relying on process env variables." -ForegroundColor Yellow
}

if (-not $env:STRIPE_SECRET_KEY) { Write-Host 'STRIPE_SECRET_KEY not found in environment. Aborting.' -ForegroundColor Red; exit 1 }

# Get list of session_id values with NULL metadata
Write-Host "Querying DB for sesion_pago rows with null metadata..."
$cmd = "docker exec -i api-recetas-postgres psql -U postgres -d api_recetas_postgres -t -A -c 'SELECT session_id FROM sesion_pago WHERE metadata IS NULL AND session_id IS NOT NULL ORDER BY fecha_creacion DESC;'"
$rows = Invoke-Expression $cmd | Where-Object { $_ -and $_.Trim().Length -gt 0 }

if (-not $rows) { Write-Host 'No sessions with NULL metadata found.'; exit 0 }

Write-Host "Found $($rows.Count) session(s) to repair.`n"

# Helper: fetch Stripe session
function Get-StripeSession($sessionId) {
    try {
        $uri = "https://api.stripe.com/v1/checkout/sessions/$sessionId"
        $hdr = @{ Authorization = "Bearer $($env:STRIPE_SECRET_KEY)" }
        $s = Invoke-RestMethod -Method Get -Uri $uri -Headers $hdr -ErrorAction Stop
        return $s
    } catch {
        Write-Host ("Failed to GET Stripe session {0}: {1}" -f $sessionId, $_.Exception.Message) -ForegroundColor Yellow
        return $null
    }
}

# Process each session
foreach ($sessionId in $rows) {
    $sessionId = $sessionId.Trim()
    Write-Host "Processing session: $sessionId"
    $s = Get-StripeSession $sessionId
    if (-not $s) { continue }

    $meta = $s.metadata
    if ($meta -eq $null) { Write-Host "Stripe returned no metadata for $sessionId" -ForegroundColor Yellow }

    # Prepare JSON string for psql (use jsonb_build_object fallback if empty)
    if ($meta -and $meta.psobject.Properties.Count -gt 0) {
        $metaJson = $meta | ConvertTo-Json -Depth 5
        # Escape single quotes for SQL literal
        $esc = $metaJson -replace "'","''"
        $sqlUpdate = "UPDATE sesion_pago SET metadata = '$esc'::jsonb WHERE session_id = '$sessionId';"
    } else {
        $sqlUpdate = "UPDATE sesion_pago SET metadata = jsonb_build_object('donacion_id', NULL) WHERE session_id = '$sessionId';"
    }

    Write-Host "SQL update: $sqlUpdate"
    if ($DryRun) { Write-Host "Dry run: skipping DB update"; continue }

    # Execute update
        # Use single quotes around the SQL passed to psql to avoid PowerShell parsing issues
        $exec = "docker exec -i api-recetas-postgres psql -U postgres -d api_recetas_postgres -c '$sqlUpdate'"
    try {
        Write-Host "Applying DB update..."
        $out = Invoke-Expression $exec
        Write-Host $out
    } catch {
        Write-Host ("DB update failed for {0}: {1}" -f $sessionId, $_.Exception.Message) -ForegroundColor Red
        continue
    }

    # Call backend verify endpoint to reconcile donation
    try {
        Write-Host "Calling backend verify-session for $sessionId"
        $login = Invoke-RestMethod -Method Post -Uri 'http://localhost:8081/auth/login' -Body (ConvertTo-Json @{ email='admin@recetas.com'; password='cast1301' }) -ContentType 'application/json'
        $token = $login.token
        $verify = Invoke-RestMethod -Method Post -Uri 'http://localhost:8081/donaciones/verify-session' -Headers @{ Authorization = "Bearer $token" } -Body (ConvertTo-Json @{ sessionId = $sessionId }) -ContentType 'application/json'
        Write-Host "Verify response:"; Write-Host (ConvertTo-Json $verify -Depth 5)
    } catch {
        Write-Host ("verify-session failed for {0}: {1}" -f $sessionId, $_.Exception.Message) -ForegroundColor Yellow
    }

}

Write-Host "Done."
