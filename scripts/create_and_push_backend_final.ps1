<#
.SYNOPSIS
  Crea una rama limpia `Backend_Final_2.0` (o `Backend_Final_2.0_YYYYMMDD_HHMMSS` si existe)
  sin la carpeta `backups/` ni artefactos pesados, y la sube al remote `colleague` (o `origin`).

.PARAMETER ReplaceRemoteBackend
  Si se proporciona, al final forzará la rama remota `backend` a apuntar a la nueva rama.

USAGE
  powershell -ExecutionPolicy Bypass -File .\scripts\create_and_push_backend_final.ps1
  # Para forzar reemplazo de backend remoto:
  powershell -ExecutionPolicy Bypass -File .\scripts\create_and_push_backend_final.ps1 -ReplaceRemoteBackend
# Opciones adicionales:
#  -SshKeyPath <ruta>    : Ruta a la clave privada SSH que se añadirá al agente antes del push (ej: C:\Users\cla\.ssh\id_ed25519)
#  -ForceRemoteUrl <url> : Forzar una URL remota concreta para el remote seleccionado (ej: "cla.sanchezt@duocuc.cl:~/repos/Recetas-Del-Mundo.git")

NOTES
  - Asegúrate de tener git en PATH y permisos de push al remoto `colleague`.
  - Si usas Git Bash, puedes iniciar el agente con: eval "$(ssh-agent -s)" y luego ssh-add ~/.ssh/id_ed25519
  - En Windows puedes iniciar el servicio OpenSSH Agent: Start-Service ssh-agent; luego ssh-add C:\path\to\key
  - El script intentará iniciar el agente y añadir la clave si pasas -SshKeyPath.
#>

param(
  [switch]$ReplaceRemoteBackend,
  [string]$SshKeyPath,
  [string]$ForceRemoteUrl
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[ERROR] $m" -ForegroundColor Red }
function Die($m){ Err $m; exit 1 }

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  # Intentar localizar git en rutas comunes de Git for Windows
  $common = @(
    'C:\Program Files\Git\cmd\git.exe',
    'C:\Program Files (x86)\Git\cmd\git.exe',
    'C:\Program Files\Git\bin\git.exe',
    'C:\Program Files\Git\usr\bin\git.exe'
  )
  $found = $common | Where-Object { Test-Path $_ } | Select-Object -First 1
  if ($found) {
    $gitDir = Split-Path $found -Parent
    $env:Path = "$gitDir;$env:Path"
  Info "git encontrado en $found - PATH actualizado para esta sesión"
  } else {
    # intentar where.exe (Git Bash/Windows PATH)
    try { $where = (& where.exe git) -split "\r?\n" | Select-Object -First 1 } catch { $where = $null }
    if ($where -and (Test-Path $where)) {
      $gitDir = Split-Path $where -Parent
      $env:Path = "$gitDir;$env:Path"
  Info "git encontrado via where.exe en $where - PATH actualizado para esta sesión"
    } else {
      Die "git no está disponible en PATH. Instala Git for Windows o abre Git Bash y vuelve a intentar."
    }
  }
}

Push-Location (Get-Location)
try {
  # Evitar que salidas de comandos externos (git) se conviertan en errores terminantes
  $prevErrorAction = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  # Detect remote to use
  $remotes = git remote
  if ($remotes -match '^colleague$') { $remote = 'colleague' }
  elseif ($remotes -match '^origin$') { $remote = 'origin' }
  else { Die "No se encontró 'colleague' ni 'origin'. Ejecuta 'git remote -v' para revisar." }

  # Fix colleague URL if it points at duocuc.cl -> prefer SSH to GitHub (more robust)
  if ($remote -eq 'colleague') {
    try { $colUrl = git remote get-url colleague 2>$null } catch { $colUrl = $null }
    if ($colUrl -and $colUrl -match 'duocuc\.cl') {
      Warn "Remote 'colleague' apunta a $colUrl (host detectado en duocuc.cl)."
      if ($ForceRemoteUrl) {
        Info "Se solicitó ForceRemoteUrl. Ajustando 'colleague' a: $ForceRemoteUrl"
        git remote set-url colleague $ForceRemoteUrl
        Info "Remote colleague ahora: $(git remote get-url colleague)"
      } else {
        Warn "No se proporcionó ForceRemoteUrl: mantendré la URL detectada. Si quieres usar tu cuenta en ese host, vuelve a ejecutar el script con -ForceRemoteUrl 'cla.sanchezt@duocuc.cl:...'."
      }
    }
  }

  Info "Usando remote: $remote"

  # Detectar rama o commit actual (puede ser detached HEAD)
  $origBranchName = & git symbolic-ref -q --short HEAD 2>$null
  if ($origBranchName) {
    $origRef = $origBranchName
    Info "Rama actual: $origRef"
  } else {
    $origRef = (& git rev-parse --verify HEAD 2>$null)
    if ($origRef) { Info "HEAD detached en commit: $origRef" } else { Info "HEAD no disponible; trabajaremos con snapshot del working tree" }
  }

  # Crear snapshot del working tree (excluye .git y backups)
  $tsSnap = Get-Date -Format 'yyyyMMdd_HHmmss'
  $tmp = Join-Path $env:TEMP "repo_snapshot_$tsSnap"
  if (-not (Test-Path $tmp)) { New-Item -Path $tmp -ItemType Directory | Out-Null }
  Info "Creando snapshot del working tree en: $tmp"
  $root = (Get-Location).Path
  $items = Get-ChildItem -Path $root -Recurse -Force -File | Where-Object { $_.FullName -notmatch '\\.git\\' -and $_.FullName -notmatch '\\backups\\' }
  foreach ($f in $items) {
    $rel = $f.FullName.Substring($root.Length + 1)
    $dest = Join-Path $tmp $rel
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) { New-Item -Path $destDir -ItemType Directory -Force | Out-Null }
    Copy-Item -Path $f.FullName -Destination $dest -Force
  }

  # Ensure .gitignore has backups/
  if (-not (Test-Path .gitignore)) { New-Item -Path .gitignore -ItemType File -Force | Out-Null }
  if (-not (Select-String -Path .gitignore -Pattern '^backups/' -Quiet -ErrorAction SilentlyContinue)) {
    Add-Content -Path .gitignore -Value "`nbackups/"
    git add .gitignore
    git commit -m "chore: ignore backups/ artifacts" 2>$null
    if ($LASTEXITCODE -ne 0) { Warn "No se creó commit para .gitignore (posible sin cambios)." } else { Info "Añadido backups/ a .gitignore" }
  } else { Info ".gitignore ya contiene backups/" }

  # Choose branch name, avoid collision
  $base = 'Backend_Final_2.0'
  $newBranch = $base
  $exists = git branch --list $newBranch
  if ($exists) {
    $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
    $newBranch = "${base}_$ts"
    Info "La rama $base ya existe localmente. Usando $newBranch en su lugar."
  }

  Info "Creando rama orphan: $newBranch"
  # Capturar salida de git para diagnostico
  $out = & git checkout --orphan $newBranch 2>&1
  if ($LASTEXITCODE -ne 0) { Die "Error al crear rama orphan: $out" }

  # Clear index and working tree (keep files)
  git reset --hard 2>$null

  # Restaurar archivos desde el snapshot temporal (en lugar de depender de HEAD)
  Info "Restaurando archivos desde el snapshot temporal"
  $snapItems = Get-ChildItem -Path $tmp -Recurse -Force -File
  foreach ($f in $snapItems) {
    $rel = $f.FullName.Substring($tmp.Length + 1)
    $dest = Join-Path $root $rel
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) { New-Item -Path $destDir -ItemType Directory -Force | Out-Null }
    Copy-Item -Path $f.FullName -Destination $dest -Force
  }

  # Remove large artifacts from index
  Info "Eliminando de index: backups/, Springboot/target/*.jar, app.jar (si existen)"
  git rm -r --cached --ignore-unmatch backups 2>$null
  git rm --cached --ignore-unmatch Springboot/target/*.jar 2>$null
  git rm --cached --ignore-unmatch app.jar 2>$null

  # Add and commit snapshot
  git add -A
  $c = git commit -m "chore: snapshot clean for $newBranch (excludes backups and artifacts)" 2>&1
  if ($LASTEXITCODE -ne 0) { Die "Error en commit: $c" }

  Info "Pushing $newBranch to remote $remote"

  # Si se indica una clave SSH, intentar iniciar/usar el agente y añadir la clave
  if ($SshKeyPath) {
    if (-not (Test-Path $SshKeyPath)) {
      Warn "SshKeyPath especificado pero no existe: $SshKeyPath"
    } else {
      Info "Intentando iniciar ssh-agent y añadir la clave: $SshKeyPath"
      try {
        # Primero: intentar usar el servicio OpenSSH (Windows)
        $svc = Get-Service -Name ssh-agent -ErrorAction SilentlyContinue
        if ($svc) {
          if ($svc.Status -ne 'Running') { Start-Service ssh-agent -ErrorAction SilentlyContinue }
          Info "Servicio ssh-agent disponible y en ejecución"
        }

        # Localizar ejecutables de OpenSSH o Git (ssh-agent, ssh-add, ssh)
        $candidates = @(
          'C:\\Windows\\System32\\OpenSSH',
          'C:\\Program Files\\Git\\usr\\bin',
          'C:\\Program Files (x86)\\Git\\usr\\bin',
          'C:\\Program Files\\Git\\bin'
        )
        $sshAgentExe = $null; $sshAddExe = $null; $sshExe = $null
        foreach ($d in $candidates) {
          if (Test-Path $d) {
            $pathAgent = Join-Path $d 'ssh-agent.exe'
            if ((-not $sshAgentExe) -and (Test-Path $pathAgent)) { $sshAgentExe = $pathAgent }
            $pathAdd = Join-Path $d 'ssh-add.exe'
            if ((-not $sshAddExe) -and (Test-Path $pathAdd)) { $sshAddExe = $pathAdd }
            $pathSsh = Join-Path $d 'ssh.exe'
            if ((-not $sshExe) -and (Test-Path $pathSsh)) { $sshExe = $pathSsh }
          }
        }

        # Si ssh-add ya funciona (agente heredado), intentar añadir directamente
        $addOk = $false
        try {
          $probe = & ssh-add -l 2>&1
          if ($LASTEXITCODE -eq 0) { Info "ssh-add probe OK"; $addOk = $true }
        } catch { }

        if (-not $addOk) {
          # Si hay ssh-agent.exe disponible, iniciarlo y parsear la salida para exportar variables
          if ($sshAgentExe) {
            Info "Iniciando ssh-agent via: $sshAgentExe"
            $agentOut = & $sshAgentExe -s 2>&1
            # salida como: SSH_AUTH_SOCK=/tmp/ssh-XXXX/agent.PID; export SSH_AUTH_SOCK; SSH_AGENT_PID=NNNN; export SSH_AGENT_PID; echo Agent pid NNNN;
            if ($agentOut) {
              # Buscar SSH_AUTH_SOCK
              if ($agentOut -match 'SSH_AUTH_SOCK=([^;]+);') { $env:SSH_AUTH_SOCK = $matches[1]; Info "SSH_AUTH_SOCK seteado: $($env:SSH_AUTH_SOCK)" }
              if ($agentOut -match 'SSH_AGENT_PID=([0-9]+);') { $env:SSH_AGENT_PID = $matches[1]; Info "SSH_AGENT_PID seteado: $($env:SSH_AGENT_PID)" }
            }
          } else {
            Warn "No se encontró ssh-agent.exe; si usas Git Bash inicia el agente manualmente: eval \"$(ssh-agent -s)\""
          }

          # Determinar ruta a ssh-add
          if (-not $sshAddExe) {
            $sshAddExe = Get-Command ssh-add -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue
          }

          if (-not $sshAddExe) {
            Warn "No se encontró ssh-add.exe en ubicaciones habituales. Intentando 'ssh-add' en PATH..."
            $sshAddExe = 'ssh-add'
          }

          # Añadir la clave usando el ejecutable detectado
          try {
            Info "Ejecutando ssh-add: $sshAddExe $SshKeyPath"
            $addOut = & $sshAddExe $SshKeyPath 2>&1
            if ($LASTEXITCODE -ne 0) { Warn "ssh-add falló: $addOut" } else { Info "Clave añadida al agente: $SshKeyPath" }
          } catch {
            Warn "ssh-add (final) falló: $_"
          }
        } else {
          # Ya había un agente funcional: añadir la clave
          try {
            $addOut = & ssh-add $SshKeyPath 2>&1
            if ($LASTEXITCODE -ne 0) { Warn "ssh-add falló: $addOut" } else { Info "Clave añadida al agente: $SshKeyPath" }
          } catch { Warn "ssh-add falló: $_" }
        }
      } catch {
        Warn "No se pudo iniciar/añadir clave al agente: $_"
      }
    }
  }

  $p = git push -u $remote $newBranch 2>&1
  if ($LASTEXITCODE -ne 0) {
    Err "Push failed (first attempt): $p"
    # Si falla por HTTP/timeout o tamaños, intentar cambiar a SSH y reintentar una vez
    try {
      # Si se pasó ForceRemoteUrl, ya la establecimos arriba; si no, intentar cambiar a SSH de GitHub
      if ($ForceRemoteUrl) {
        Info "Usando ForceRemoteUrl para reintento: $(git remote get-url $remote)"
      } else {
        Info "Intentando reintento cambiando remote a SSH de GitHub y reintentando push..."
        git remote set-url $remote git@github.com:TioPig/Recetas-Del-Mundo.git
        Info "Remote $remote actualizado a SSH: $(git remote get-url $remote)"
      }
      $p2 = git push -u $remote $newBranch 2>&1
      if ($LASTEXITCODE -ne 0) { Die "Reintento falló: $p2" }
      Info "Push completado tras reintento: $remote/$newBranch"
    } catch {
      Die "No se pudo reintentar push: $_`nSalida original: $p"
    }
  }
  Info "Branch pushed: $remote/$newBranch"

  if ($ReplaceRemoteBackend) {
    Info "Reemplazando remote 'backend' por $newBranch (forzando)..."
    $pp = git push --force-with-lease $remote $newBranch:backend 2>&1
    if ($LASTEXITCODE -ne 0) { Die "Fallo al forzar reemplazo de backend: $pp" }
    Info "Reemplazo completado: $remote/backend ahora apunta a $newBranch"
  }

  # Return to original branch or commit if available
  if ($origRef) {
    Info "Volviendo a la referencia original: $origRef"
    git checkout $origRef 2>$null
  } else {
    Info "No hay referencia original disponible para restaurar (HEAD desconocido)."
  }

  # Limpiar snapshot temporal
  try { Remove-Item -Recurse -Force -LiteralPath $tmp -ErrorAction SilentlyContinue } catch { }
  Info "Hecho. Nueva rama: $newBranch"

  # Restaurar comportamiento de errores
  $ErrorActionPreference = $prevErrorAction
} catch {
  $ex = $_
  # Mostrar excepción completa y salir
  Die "Fallo inesperado: $ex`nDetalle: $($ex.Exception.Message)"
} finally { Pop-Location }
