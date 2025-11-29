param(
    [Parameter(Mandatory=$true)][string]$SessionId,
    [string]$BaseUrl = "http://168.181.187.137:8081",
    [string]$Email = "admin@recetas.com",
    [string]$Password = "cast1301"
)

function Fail($msg) { Write-Host "ERROR: $msg" -ForegroundColor Red; exit 1 }

Write-Host "Verify remote session -> $BaseUrl, sessionId=$SessionId"

# 1) Login
$loginUrl = "$BaseUrl/auth/login"
try {
    $loginResp = Invoke-RestMethod -Method Post -Uri $loginUrl -Body (@{ email = $Email; password = $Password } | ConvertTo-Json) -ContentType 'application/json' -ErrorAction Stop
} catch {
    Fail "Login failed: $($_.Exception.Message)"
}
if (-not $loginResp.token) { Fail "No token returned from login: $(ConvertTo-Json $loginResp)" }
$token = $loginResp.token
Write-Host "Login OK. Token length: $($token.Length)"

# 2) Verify session
$verifyUrl = "$BaseUrl/donaciones/verify-session"
try {
    $verifyResp = Invoke-RestMethod -Method Post -Uri $verifyUrl -Headers @{ Authorization = "Bearer $token" } -Body (@{ sessionId = $SessionId } | ConvertTo-Json) -ContentType 'application/json' -ErrorAction Stop
    Write-Host "verify-session OK:" -ForegroundColor Green
    Write-Host (ConvertTo-Json $verifyResp -Depth 10)
} catch {
    Write-Host "verify-session failed: $($_.Exception.Message)" -ForegroundColor Yellow
    if ($_.Exception.Response) {
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $body = $reader.ReadToEnd()
            Write-Host "Response body:" -ForegroundColor Cyan
            Write-Host $body
        } catch {
            Write-Host "No response body available" -ForegroundColor Red
        }
    }
}
