param(
    [Parameter(Mandatory=$false)]
    [double]$Amount = 1021.0,
    [Parameter(Mandatory=$false)]
    [string]$AmountRaw,
    [switch]$OpenBrowser
)

Set-Location $PSScriptRoot\..\
$base = 'http://localhost:8081'
Write-Host "Checking backend health at $base/actuator/health..."
try {
    $h = Invoke-RestMethod -Method Get -Uri "$base/actuator/health" -TimeoutSec 5
    Write-Host "Health: $($h.status)"
} catch {
    Write-Host "Health check failed: $_"
    exit 1
}

Write-Host 'Logging in as admin@recetas.com'
try {
    $login = Invoke-RestMethod -Method Post -Uri "$base/auth/login" -Body (ConvertTo-Json @{ email='admin@recetas.com'; password='cast1301' }) -ContentType 'application/json' -TimeoutSec 10
} catch {
    Write-Host "Login failed: $_"
    exit 1
}
$token = $login.token
Write-Host "TOKEN: $token"

Write-Host "Creating donation session for amount $Amount..."
if ($AmountRaw) {
    # Send amount as a JSON string so controller treats it as units (scale > 0)
    $body = @{ amount = "$AmountRaw"; currency = 'usd' } | ConvertTo-Json -Depth 5
    Write-Host "Using raw JSON body (amount as string): $body"
} else {
    # Ensure decimal scale is preserved by using a double (1021.0) or string value
    $body = @{ amount = $Amount; currency = 'usd' } | ConvertTo-Json -Depth 5
    Write-Host "Request body: $body"
}
try {
    $create = Invoke-RestMethod -Method Post -Uri "$base/donaciones/create-session" -Body $body -ContentType 'application/json' -Headers @{ Authorization = "Bearer $token" } -TimeoutSec 30
    Write-Host "Create response:" -ForegroundColor Green
    $create | ConvertTo-Json -Depth 5 | Write-Host
    if ($create.url) {
        Write-Host "Stripe Checkout URL: $($create.url)" -ForegroundColor Cyan
        if ($OpenBrowser) {
            Write-Host 'Opening browser...'
            Start-Process $create.url
        }
    } else {
        Write-Host 'No Stripe URL returned (maybe local flow).'
    }
} catch {
    Write-Host "Create session failed: $_"
    exit 1
}

Write-Host 'Done.'
