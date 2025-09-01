Se han eliminado los scripts de desarrollo (dev helpers) del repositorio por seguridad.

Lista de scripts anteriormente presentes (para referencia, NO están activos):
- update_user_pw.ps1
- update_all_recetas.ps1
- run_bcrypt.ps1
- post_comment.ps1
- login_and_comment.ps1
- get_hash.ps1
- gen_jwt2.ps1
- gen_jwt.ps1
- create_user_and_comment.ps1
- BCryptGen.java

Si necesitás volver a generarlos para pruebas locales, recrealos en una carpeta local fuera del control de versiones y tené cuidado de no exponer endpoints dev en producción.

Notas adicionales:
- El endpoint `/tools/hash` sigue existiendo en el código solo cuando la aplicación se ejecuta con el profile `dev`.
- Además, el endpoint está protegido por la propiedad `tools.enabled` (false por defecto). Para habilitarlo en desarrollo, inicia la app con el profile `dev` y define `-Dtools.enabled=true`.

