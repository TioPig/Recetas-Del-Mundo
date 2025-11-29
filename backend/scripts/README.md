README — scripts para entorno local

Propósito
--------
Este directorio contiene scripts útiles para pruebas locales del backend. En particular, el script `generate_and_call_jwt.ps1` genera un JWT HMAC-SHA256 firmado con la misma clave (`JWT_SECRET`) definida en `docker-compose.yml` y llama al endpoint administrativo `/admin/visits/flush` para forzar un flush de visitas.

Advertencia de seguridad
------------------------
- NO incluyas secretos (como `JWT_SECRET` real) en commits públicos.
- El script actual usa la clave definida en el propio archivo; si usas un secret real, pásalo por variable de entorno o edita el script localmente en un entorno seguro.
- Este script es solo para pruebas locales en entornos de desarrollo.

Requisitos
---------
- PowerShell (Windows) o pwsh en otros entornos.
- El backend corriendo en `http://localhost:8081` (o ajusta la URL dentro del script).
- Docker-compose por defecto en este repo configura `JWT_SECRET` en el servicio `backend`. El script usa por defecto esa misma cadena cuando trabajas localmente con compose.

Uso (rápido)
-------------
1. Ejecutar el script desde la raíz del repositorio (o usar la ruta absoluta):

```powershell
# Desde la raíz del repo
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\generate_and_call_jwt.ps1
```

2. El script imprimirá el token generado y la respuesta del endpoint. Si devuelve `{"exito":true,"mensaje":"Flush executed"}` entonces el flush se ejecutó correctamente.

Parámetros / Edición
--------------------
- Si quieres usar un `JWT_SECRET` distinto al que está en `docker-compose.yml`, edita el script y asigna la variable `$secret` al inicio del archivo o pasa tu propio valor mediante un pequeño wrapper que exporte la variable y luego invoque el script.
- Para cambiar la URL objetivo, modifica la llamada a `Invoke-WebRequest` dentro del script.

Mejoras recomendadas
---------------------
- Añadir una verificación temprana que impida ejecutar el script si el secret es el placeholder (`change_me_...`).
- No versionar scripts que contengan secretos: mantenlos en un directorio `scripts/local` ignorado por git o usa variables de entorno en vez de codificar la clave.

Eliminar el script
------------------
Si deseas eliminar el script del repositorio por motivos de seguridad, ejecuta:

```powershell
Remove-Item .\scripts\generate_and_call_jwt.ps1
Remove-Item .\scripts\README.md
```

Contacto
--------
Si quieres que lo adapte (por ejemplo: generar tokens con claims distintos, usar RS256 con clave privada, o agregar validaciones), dime qué necesitas y lo preparo.

Uso de pruebas E2E de donaciones
-------------------------------
- Script canonical: `e2e_automated.ps1` — script unificado que crea una sesión de donación, opcionalmente abre el Checkout, puede simular un webhook firmado y llama a `verify-session`.
- Parámetros: `-AmountCents`, `-Interactive`, `-SimulateWebhook`, `-ExportCsv`.

Deprecated / eliminables (ya consolidados)
-------------------------------------------
Estos scripts relacionados con la creación/verificación de sesiones de donación fueron reemplazados por `e2e_automated.ps1` y pueden borrarse si quieres mantener sólo el script unificado:

- `create_new_session.ps1`
- `create_multiple_sessions.ps1`
- `temp_e2e.ps1`
- `verify_session_tests.ps1`
- `verify_and_check_db.ps1`
- `create_and_verify_local.ps1`
- `mark_donation_paid.ps1`
- `send_stripe_webhook.py`
- `call_verify_session.py`
- `sessions_created.json`

Si quieres que elimine esos archivos ahora (commit + push), dime y procedo.
