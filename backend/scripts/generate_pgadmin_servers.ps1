Param()
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Resolve-Path (Join-Path $ScriptDir '..') | Select-Object -ExpandProperty Path
$Template = Join-Path $RootDir 'pgadmin\servers.json.template'
$Out = Join-Path $RootDir 'pgadmin\servers.json'

if (-not (Test-Path $Template)) { Write-Error "Template not found: $Template"; exit 1 }

# Load .env if present
$envFile = Join-Path $RootDir '.env'
if (Test-Path $envFile) {
  Get-Content $envFile | ForEach-Object {
    $line = $_.Trim()
    if (-not $line -or $line.StartsWith('#')) { return }
    $idx = $line.IndexOf('=')
    if ($idx -gt 0) {
      $k = $line.Substring(0,$idx).Trim()
      $v = $line.Substring($idx+1).Trim('"').Trim()
      if ($k) { Set-Item -Path ("Env:{0}" -f $k) -Value $v }
    }
  }
}

$pass = $env:POSTGRES_PASSWORD
if (-not $pass) { Write-Warning 'POSTGRES_PASSWORD not set in environment/.env. Generated servers.json will have empty password.' }

(Get-Content $Template) -replace '<POSTGRES_PASSWORD>', $pass | Set-Content -Path $Out -Encoding UTF8
try { icacls $Out /inheritance:r /grant:r "$env:USERNAME:(R,W)" } catch { }
Write-Host "[OK] Generated $Out"
