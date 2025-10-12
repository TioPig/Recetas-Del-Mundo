<#
.SYNOPSIS
  Crea una nueva rama limpia a partir de la rama actual, elimina la rama antigua localmente
  y muestra los comandos recomendados para empujar y reemplazar la rama `backend` en el remoto.

.DESCRIPTION
  - Crea una rama nueva nombrada como <base> o <base>_YYYYMMDD_HHMMSS si existe.
  - Quita de index la carpeta `backups/` y artefactos grandes (Springboot/target/*.jar, app.jar).
  - Hace commit si detecta cambios.
  - Borra la rama antigua localmente (si es diferente de la nueva).
  - Muestra los comandos seguros para empujar y forzar la rama remota desde un shell que tenga el agente SSH (Git Bash recomendado).

.PARAMETER BaseName
  Nombre base de la rama (por defecto Backend_Final_2.0).

.PARAMETER ForceLocalReplace
  Si se proporciona, realizará la eliminación de la rama local antigua sin pedir confirmación.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\scripts\replace_current_with_clean_branch.ps1

#>

param(
  [string]$BaseName = 'Backend_Final_2.0',
  [switch]$ForceLocalReplace
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[ERROR] $m" -ForegroundColor Red }
function Die($m){ Err $m; exit 1 }

# Ensure git available
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  $candidates = @(
    'C:\\Program Files\\Git\\cmd\\git.exe',
    'C:\\Program Files (x86)\\Git\\cmd\\git.exe',
    'C:\\Program Files\\Git\\bin\\git.exe'
  )
  $g = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
  if ($g) {
    $gitExe = $g
    $gitDir = Split-Path $g -Parent
    $env:Path = "$gitDir;$env:Path"
    Info "git encontrado en $g - PATH actualizado para esta sesión"
  } else {
    Die "git no está disponible en PATH. Instala Git for Windows o abre Git Bash y vuelve a intentar."
  }
} else {
  $gitExe = (Get-Command git).Source
}

Push-Location (Get-Location)
try {
  $curr = (& git rev-parse --abbrev-ref HEAD 2>$null).Trim()
  if (-not $curr) { Die "No se pudo detectar la rama actual. Asegúrate de ejecutar esto dentro de un repo git." }
  Info "Rama actual: $curr"

  # Build new branch name
  $new = $BaseName
  $exists = (& git branch --list $new)
  if ($exists) {
    $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
    $new = "${BaseName}_$ts"
    Info "La rama base '$BaseName' ya existe. Usando nombre nuevo: $new"
  }

  # Create new branch from current commit
  Info "Creando rama nueva '$new' desde '$curr'"
  & git branch $new $curr 2>&1 | ForEach-Object { Write-Host $_ }
  & git checkout $new 2>&1 | ForEach-Object { Write-Host $_ }

  # Remove backups and artifacts from index
  Info "Eliminando de index: backups/, Springboot/target/*.jar, app.jar"
  & git rm -r --cached --ignore-unmatch backups 2>$null | Out-Null
  & git rm --cached --ignore-unmatch "Springboot/target/*.jar" 2>$null | Out-Null
  & git rm --cached --ignore-unmatch app.jar 2>$null | Out-Null

  # Commit only if there are changes
  & git add -A
  $status = (& git status --porcelain)
  if ($status) {
    Info "Cambios detectados en index. Creando commit de limpieza."
    & git commit -m "chore: cleaned artifacts for $new" 2>&1 | ForEach-Object { Write-Host $_ }
  } else { Info "No hay cambios para commitear en la nueva rama." }

  # Delete old branch locally (if different)
  if ($curr -ne $new) {
    if ($ForceLocalReplace) {
      Info "Eliminando rama local antigua: $curr"
      & git branch -D $curr 2>&1 | ForEach-Object { Write-Host $_ }
    } else {
      $confirm = Read-Host "Eliminar la rama local antigua '$curr'? (y/n)"
      if ($confirm -match '^[Yy]') {
        Info "Eliminando rama local antigua: $curr"
        & git branch -D $curr 2>&1 | ForEach-Object { Write-Host $_ }
      } else { Info "No se eliminó la rama antigua." }
    }
  } else { Info "La rama nueva y la antigua tienen el mismo nombre; no se elimina nada." }

  Info "Operación local completada. Nueva rama: $new"

  Write-Host "`nSiguientes pasos recomendados para publicar y reemplazar remote/backend:" -ForegroundColor Green
  Write-Host "# 1) Asegúrate de tener agente SSH con tu clave cargada (ej: en Git Bash: eval \"$(ssh-agent -s)\" ; ssh-add ~/.ssh/id_ed25519)"
  Write-Host "# 2) Ajusta remote si es necesario: git remote set-url colleague git@github.com:TioPig/Recetas-Del-Mundo.git"
  Write-Host "# 3) Empuja la rama nueva: git push -u colleague $new"
  Write-Host "# 4) Reemplaza la rama backend en remoto (recomendado --force-with-lease): git push --force-with-lease colleague $new:backend"

} catch {
  Die "Fallo inesperado: $_"
} finally { Pop-Location }
