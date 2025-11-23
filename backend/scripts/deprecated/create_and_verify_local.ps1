$base='http://localhost:8081'
$Email='admin@recetas.com'
$Password='cast1301'
$Amount=33300

function Fail($m){ Write-Host "ERROR: $m" -ForegroundColor Red; exit 1 }
try {
    $login=Invoke-RestMethod -Method Post -Uri "$base/auth/login" -Body (@{email=$Email; password=$Password} | ConvertTo-Json) -ContentType 'application/json' -ErrorAction Stop
    $token=$login.token
    Write-Host 'Login OK. Token length:' $token.Length
    $headers = @{ Authorization = "Bearer $token" }

    $create = Invoke-RestMethod -Method Post -Uri "$base/donaciones/create-session" -Headers $headers -Body (@{ amount = $Amount; currency = 'usd'; idReceta = $null } | ConvertTo-Json) -ContentType 'application/json' -ErrorAction Stop
    Write-Host 'Create-session response:'
    Write-Host (ConvertTo-Json $create -Depth 6)
    $sessionId = $null
    if ($create.sessionId) { $sessionId = $create.sessionId } elseif ($create.sesion_pago -and $create.sesion_pago.sessionId) { $sessionId = $create.sesion_pago.sessionId } elseif ($create.sesion_pago -and $create.sesion_pago.session_id) { $sessionId = $create.sesion_pago.session_id }
    if (-not $sessionId) { Fail 'No sessionId returned' }
    Write-Host 'SessionId:' $sessionId

    # Now call verify-session
    Write-Host 'Calling verify-session...'
    try {
        $verify = Invoke-RestMethod -Method Post -Uri "$base/donaciones/verify-session" -Headers $headers -Body (@{ sessionId = $sessionId } | ConvertTo-Json) -ContentType 'application/json' -ErrorAction Stop
        Write-Host 'verify-session OK'
        Write-Host (ConvertTo-Json $verify -Depth 10)
    } catch {
        Write-Host 'verify-session failed:' $_.Exception.Message -ForegroundColor Yellow
        if ($_.Exception.Response) {
            try { $sr = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream()); $txt = $sr.ReadToEnd(); Write-Host 'Response body:'; Write-Host $txt } catch { Write-Host 'No response body available' }
    }
}
} catch { Fail $_.Exception.Message }
