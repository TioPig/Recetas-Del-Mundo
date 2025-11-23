param(
    [int]$iterations = 50,
    [string]$baseUrl = $(if ($env:E2E_BASE_URL) { $env:E2E_BASE_URL } else { 'http://localhost:8081' }),
    [string]$adminEmail = $(if ($env:E2E_EMAIL) { $env:E2E_EMAIL } else { '<ADMIN_EMAIL>' }),
    [string]$adminPass = $(if ($env:E2E_PASSWORD) { $env:E2E_PASSWORD } else { '<PASSWORD>' }),
    [string]$logFile = "logs\repro_ingredientes.log"
)

# Ensure logs dir
if (-not (Test-Path (Split-Path $logFile))) { New-Item -ItemType Directory -Path (Split-Path $logFile) -Force | Out-Null }
"Starting repro run at $(Get-Date -Format o)" | Out-File -FilePath $logFile -Encoding utf8 -Append

function Log($msg){ $t = "$(Get-Date -Format o) `t $msg"; Write-Host $t; $t | Out-File -FilePath $logFile -Encoding utf8 -Append }

try {
    Log "Login..."
    $loginBody = @{ email = $adminEmail; password = $adminPass }
    $login = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -ContentType 'application/json' -Body ($loginBody | ConvertTo-Json)
    if (-not $login -or -not $login.token) { Log "Login failed"; exit 2 }
    $token = $login.token
    $headers = @{ Authorization = ("Bearer {0}" -f $token) }
    Log "Login OK. Token length: $($token.length)"

    Log "Creating recipe..."
    $create = @{
        nombre = ("E2E Repro {0}" -f (Get-Date -Format yyyyMMddHHmmss))
        urlImagen = 'https://example.com/e2e.jpg'
        preparacion = 'prep'
        idCat = 26
        idPais = 18
        idUsr = 1
        estado = 1
        ingredientes = @(@{ nombre = 'A' }, @{ nombre = 'B' })
    }
    $created = Invoke-RestMethod -Uri "$baseUrl/recetas" -Method POST -ContentType 'application/json' -Body ($create | ConvertTo-Json -Depth 6) -Headers $headers
    $id = $null
    if ($created -and $created.data -and $created.data.idReceta) { $id = $created.data.idReceta } elseif ($created -and $created.idReceta) { $id = $created.idReceta }
    if (-not $id) { Log "Could not create recipe - aborting"; exit 3 }
    Log "Created receta id: $id"

    Log "Replacing ingredientes once..."
    $replace = @(@{ nombre = 'A mod' }, @{ nombre = 'C new' })
    $resp = Invoke-RestMethod -Uri "$baseUrl/recetas/$id/ingredientes" -Method PUT -ContentType 'application/json' -Body ($replace | ConvertTo-Json -Depth 6) -Headers $headers
    Log "Replace response total: $($resp.total)"

    for ($i = 1; $i -le $iterations; $i++) {
        $toAdd = @(@{ nombre = ('Add-' + $i) })
        try {
            $r = Invoke-RestMethod -Uri "$baseUrl/recetas/$id/ingredientes" -Method POST -ContentType 'application/json' -Body ($toAdd | ConvertTo-Json -Depth 6) -Headers $headers -TimeoutSec 30
            Log ("POST ok {0}; total:{1}" -f $i, ($r.total -as [string]))
        } catch {
            $err = $_.Exception.Message
            Log ("POST err {0}: {1}" -f $i, $err)
            if ($_.Exception.Response -ne $null) {
                try {
                    $s = $_.Exception.Response.GetResponseStream(); $rd = New-Object System.IO.StreamReader($s); $body = $rd.ReadToEnd(); Log ("BODY: $body")
                } catch { Log "Failed to read response stream: $($_.Exception.Message)" }
            }
            Log "Captured error on iteration $i; dumping backend logs (last 300 lines)"
            docker-compose logs --no-color --tail=300 backend | Out-File -FilePath $logFile -Encoding utf8 -Append
            Log "Exiting with code 1"
            exit 1
        }
        Start-Sleep -Milliseconds 300
    }

    Log "Completed $iterations iterations without 400"
    docker-compose logs --no-color --tail=200 backend | Out-File -FilePath $logFile -Encoding utf8 -Append
    Log "Done."
    exit 0
} catch {
    Log "Unhandled error: $($_.Exception.Message)"
    if ($_.Exception.Response -ne $null) {
        try { $s = $_.Exception.Response.GetResponseStream(); $rd = New-Object System.IO.StreamReader($s); Log ($rd.ReadToEnd()) } catch {}
    }
    docker-compose logs --no-color --tail=200 backend | Out-File -FilePath $logFile -Encoding utf8 -Append
    exit 4
}
