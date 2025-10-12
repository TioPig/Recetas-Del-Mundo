param(
  [string]$KeyPath = "$env:USERPROFILE\.ssh\id_ed25519",
  [bool]$GenerateIfMissing = $true,
  [bool]$RunPushScript = $false,
  [string]$ForceRemoteUrl
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[ERROR] $m" -ForegroundColor Red }
function Die($m){ Err $m; exit 1 }

Info "Using KeyPath: $KeyPath"

# Ensure .ssh directory
$sshDir = Split-Path $KeyPath -Parent
if (-not (Test-Path $sshDir)) {
  New-Item -ItemType Directory -Path $sshDir | Out-Null
  Info "Created directory: $sshDir"
}

if (-not (Test-Path $KeyPath)) {
  if ($GenerateIfMissing) {
    Info "Key not found; generating new ed25519 key at $KeyPath (no passphrase)."
    # Use ssh-keygen (from Git for Windows) to generate key non-interactively
    $sshKeygen = Get-Command ssh-keygen -ErrorAction SilentlyContinue
    if (-not $sshKeygen) { Die "ssh-keygen no encontrado en PATH. Abre Git Bash o instala OpenSSH/Git y vuelve a intentar." }
    & $sshKeygen -t ed25519 -f $KeyPath -N "" -C "cla.sanchezt@duocuc.cl" | Out-Null
    Info "Key generated."
  } else {
    Die "Key not found at $KeyPath and generation disabled."
  }
} else { Info "Key already exists at $KeyPath" }

# Start ssh-agent service if available
try {
  $svc = Get-Service -Name ssh-agent -ErrorAction SilentlyContinue
  if ($svc) {
    if ($svc.Status -ne 'Running') { Start-Service ssh-agent -ErrorAction SilentlyContinue }
    Info "ssh-agent service is running"
  } else {
    Info "ssh-agent service not available; ensure you run a shell with an agent (Git Bash or start agent manually)."
  }
} catch { Warn "Could not start ssh-agent service: $_" }

# Add key to agent
try {
  $addOut = & ssh-add $KeyPath 2>&1
  if ($LASTEXITCODE -ne 0) { Warn "ssh-add reported: $addOut" } else { Info "Key added to ssh-agent: $KeyPath" }
} catch { Warn "ssh-add failed: $_" }

# Print public key for copying to GitHub or server
$pub = "$KeyPath.pub"
if (Test-Path $pub) {
  Info "Public key (copy and add to GitHub or to server's authorized_keys):"
  Write-Host "`n----------------- BEGIN PUBLIC KEY -----------------`n" -ForegroundColor Green
  Get-Content $pub | ForEach-Object { Write-Host $_ }
  Write-Host "`n------------------ END PUBLIC KEY ------------------`n" -ForegroundColor Green
} else { Warn "Public key not found at $pub" }

if ($RunPushScript) {
  Info "Re-running create_and_push_backend_final.ps1 using key $KeyPath"
  $pushArgs = @()
  $pushArgs += "-SshKeyPath"; $pushArgs += $KeyPath
  if ($ForceRemoteUrl) { $pushArgs += "-ForceRemoteUrl"; $pushArgs += $ForceRemoteUrl }
  $pushArgs += "-ReplaceRemoteBackend"
  & powershell -ExecutionPolicy Bypass -File .\scripts\create_and_push_backend_final.ps1 @pushArgs
}

Info "Done. Add the public key shown above to the remote (GitHub > Settings > SSH keys) or to the server's ~/.ssh/authorized_keys, then re-run the push script or run this script again with -RunPushScript." 
