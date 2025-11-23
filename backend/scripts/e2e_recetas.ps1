param(
    [string]$baseUrl = $(if ($env:E2E_BASE_URL) { $env:E2E_BASE_URL } else { 'http://localhost:8081' }),
    [string]$adminEmail = $(if ($env:E2E_EMAIL) { $env:E2E_EMAIL } else { '<ADMIN_EMAIL>' }),
    [string]$adminPass = $(if ($env:E2E_PASSWORD) { $env:E2E_PASSWORD } else { '<PASSWORD>' })
)

Write-Host "E2E Recetas: baseUrl=$baseUrl --- Login admin: $adminEmail (credential not printed)"

function Invoke-Json {
    param($method, $uri, $body = $null, $headers = @{})
    if ($null -ne $body) {
        $json = $body | ConvertTo-Json -Depth 10
        return Invoke-RestMethod -Method $method -Uri $uri -Headers $headers -ContentType 'application/json' -Body $json
    } else {
        return Invoke-RestMethod -Method $method -Uri $uri -Headers $headers
    }
}

# Login admin
$loginBody = @{ email = $adminEmail; password = $adminPass }
$login = Invoke-Json -method POST -uri "$baseUrl/auth/login" -body $loginBody
if (-not $login -or -not $login.token) { Write-Error "Login failed"; exit 1 }
$token = $login.token
$headers = @{ Authorization = "Bearer $token" }
Write-Host "Login OK. Token length: $($token.Length)"

# 1) Create recipe with ingredients
# Obtener idCat e idPais válidos
try {
    $cats = Invoke-Json -method GET -uri "$baseUrl/categorias"
    $firstCat = $null
    if ($cats -and $cats.data -and $cats.data.Count -gt 0) { $firstCat = $cats.data[0].idCat }
    $paises = Invoke-Json -method GET -uri "$baseUrl/paises"
    $firstPais = $null
    if ($paises -and $paises.data -and $paises.data.Count -gt 0) { $firstPais = $paises.data[0].idPais }
} catch {
    Write-Warning "No se pudo obtener categorias/paises: $($_.Exception.Message)"
}

$createRecipe = @{
    nombre = "E2E Receta Test - $([DateTime]::UtcNow.ToString('yyyyMMddHHmmss'))"
    urlImagen = "https://example.com/e2e.jpg"
    preparacion = "Preparacion original"
    idCat = $firstCat
    idPais = $firstPais
    idUsr = $login.usuario.id_usr
    estado = 1
    ingredientes = @(
        @{ nombre = "Ingrediente A" },
        @{ nombre = "Ingrediente B" }
    )
}

# POST /recetas with debug
try {
    $created = Invoke-Json -method POST -uri "$baseUrl/recetas" -body $createRecipe -headers $headers
    try { Write-Host "POST /recetas response (raw): $($created | ConvertTo-Json -Depth 6)" } catch { Write-Host "POST /recetas response received (non-serializable)" }
} catch {
    Write-Error "POST /recetas failed: $($_.Exception.Message)"
    if ($_.Exception.Response -ne $null) {
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $bodyText = $reader.ReadToEnd(); Write-Host "Response body: $bodyText"
        } catch { }
    }
    exit 1
}
# extract id
if ($created -and $created.data -and $created.data.idReceta) { $recetaId = $created.data.idReceta } elseif ($created -and $created.idReceta) { $recetaId = $created.idReceta } else { Write-Error "No se pudo obtener id de receta"; exit 1 }
Write-Host "Receta creada: $recetaId"

# 2) Modificar ingredientes (PUT /recetas/{id}/ingredientes) - replace list
$newIngredients = @(
    @{ nombre = "Ingrediente A mod" },
    @{ nombre = "Ingrediente C nuevo" }
)
$updatedIngr = Invoke-Json -method PUT -uri "$baseUrl/recetas/$recetaId/ingredientes" -body $newIngredients -headers $headers
Write-Host "Ingredientes reemplazados. Respuesta: $($updatedIngr | ConvertTo-Json -Depth 5)"

# 3) Agregar ingredientes (POST /recetas/{id}/ingredientes)
$toAdd = @(
    @{ nombre = "Ingrediente D agregado" }
)
$added = Invoke-Json -method POST -uri "$baseUrl/recetas/$recetaId/ingredientes" -body $toAdd -headers $headers
Write-Host "Ingredientes agregados. Respuesta: $($added | ConvertTo-Json -Depth 5)"

# 4) Modificar preparacion de la receta (PUT /recetas/{id})
$existing = Invoke-Json -method GET -uri "$baseUrl/recetas/$recetaId" -headers $headers
# build payload preserving fields
$payload = @{}
$payload.nombre = $existing.nombre
$payload.urlImagen = $existing.urlImagen
$payload.preparacion = "Preparacion modificada por E2E"
$payload.idCat = $existing.idCat
$payload.idPais = $existing.idPais
$payload.idUsr = $existing.idUsr
$payload.estado = $existing.estado
$payload.ingredientes = $existing.ingredientes

$updatedReceta = Invoke-Json -method PUT -uri "$baseUrl/recetas/$recetaId" -body $payload -headers $headers
Write-Host "Receta actualizada. Respuesta: $($updatedReceta | ConvertTo-Json -Depth 6)"

# 5) Delete receta
$deleted = Invoke-Json -method DELETE -uri "$baseUrl/recetas/$recetaId" -headers $headers
Write-Host "Receta eliminada. Respuesta: $($deleted | ConvertTo-Json -Depth 4)"

Write-Host "E2E recetas completado con éxito."
exit 0
