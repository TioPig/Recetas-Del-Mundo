<#
.SYNOPSIS
  Crea una nueva rama limpia (sin la carpeta backups/) y la sube al remoto (colleague u origin).

USAGE
  Ejecutar desde la raíz del repositorio en PowerShell (Windows):
    pwsh -File .\scripts\create_and_push_clean_branch.ps1
  o
    powershell -ExecutionPolicy Bypass -File .\scripts\create_and_push_clean_branch.ps1

NOTAS
  - El script no borra la carpeta local `backups/` pero la excluye del commit en la nueva rama.
  - Asegúrate de tener git en PATH y credenciales configuradas.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Write-Warn([string]$m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Write-Err([string]$m){ Write-Host "[ERROR] $m" -ForegroundColor Red }

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Err "git no está disponible en PATH. Instala Git y vuelve a intentar."
  exit 1
}

Push-Location (Get-Location)
try {
  # Detect remote
  $remotes = git remote
    if ($remotes -match '^colleague$') { $remote = 'colleague' }
    elseif ($remotes -match '^origin$') { $remote = 'origin' }
    else {
      Write-Err "No se encontró 'colleague' ni 'origin' como remote. Lista de remotes:"; git remote -v; exit 1
    }

    # If colleague exists but points to an incorrect host (like duocuc.cl), fix it to the real GitHub repo URL
    if ($remote -eq 'colleague') {
      try {
        $colUrl = git remote get-url colleague 2>$null
        if ($colUrl -match 'duocuc\.cl') {
          Write-Warn "El remote 'colleague' apunta a '$colUrl' (host no resolvible). Reemplazando por la URL HTTPS de GitHub."
          git remote set-url colleague https://github.com/TioPig/Recetas-Del-Mundo.git
          Write-Info "Remote 'colleague' actualizado a: $(git remote get-url colleague)"
        }
      } catch {
        Write-Warn "No se pudo consultar la URL de 'colleague' (ignorado): $_"
      }
    }

    Write-Info "Usando remote: $remote"

  $origBranch = git rev-parse --abbrev-ref HEAD
  Write-Info "Rama actual: $origBranch"

  # Ensure backups/ ignored
  if (-not (Test-Path .gitignore)) { New-Item -Path .gitignore -ItemType File -Force | Out-Null }
  $gi = Get-Content .gitignore -Raw
  if ($gi -notmatch '(?m)^backups/') {
    Add-Content -Path .gitignore -Value "`nbackups/"
  git add .gitignore
  git commit -m "chore: ignore backups/ artifacts" 2>$null
  if ($LASTEXITCODE -ne 0) { Write-Warn "No se creó commit (.gitignore posiblemente sin cambios)" } else { Write-Info "Añadido backups/ a .gitignore" }
  } else {
    Write-Info ".gitignore ya contiene backups/"
  }

  # New branch name
  $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
  $newBranch = "backend-clean_$ts"
  Write-Info "Creando nueva rama: $newBranch"

  # Create orphan branch
  git checkout --orphan $newBranch

  # Ensure index empty
  git reset --hard

  # Check out working tree files from original branch into orphan branch
  Write-Info "Restaurando archivos desde $origBranch a la nueva rama (excepto backups/)"
  git checkout $origBranch -- .

  # Remove backups from index if present
  git rm -r --cached --ignore-unmatch backups 2>$null
  if ($LASTEXITCODE -ne 0) { Write-Info "backups/ no estaba en index" }

  # Add and commit
  git add -A
  git commit -m "chore: clean snapshot branch $newBranch (excludes backups/)"

  Write-Info "Empujando $newBranch a $remote"
  git push -u $remote $newBranch
  Write-Info "Push completado: $remote/$newBranch"

  # Return to original branch
  git checkout $origBranch
  Write-Info "Hecho. Puedes crear un PR desde '$newBranch' hacia 'backend' o 'main' en GitHub."
}
catch {
  Write-Err "Fallo: $_"
  exit 1
}
finally { Pop-Location }
