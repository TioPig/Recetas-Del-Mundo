# 🔧 Arreglo de Donaciones con Stripe

## ✅ Cambios Realizados en el Frontend

### 1. **api.js** - URL de cancelación corregida
- ❌ Antes: `/donacion/canceled`
- ✅ Ahora: `/donacion/cancel`

### 2. **App.js** - Rutas actualizadas
- Agregada ruta: `/donacion/cancel`
- Mantenida ruta legacy: `/donacion/canceled` (por compatibilidad)

### 3. **DonacionSuccess.js** - Manejo mejorado de errores
- Si el endpoint `/donaciones/verify/{sessionId}` no existe (404), muestra mensaje genérico de éxito
- Incluye el sessionId en los datos para mostrar

### 4. **Header.js** - Monto corregido
- ❌ Antes: `5.00` (dólares, causaba error de Stripe)
- ✅ Ahora: `50` (centavos = $0.50 USD, mínimo de Stripe)

## ⚠️ Cambios Necesarios en el Backend

### 1. URL de Cancelación en `.env`

Actualizar en `/home/admin/api-recetas/.env`:

```env
# Cambiar de:
DONATION_CANCEL_URL=http://recetasdelmundo.site/donacion/cancel

# A:
DONATION_CANCEL_URL=https://recetasdelmundo.site/donacion/cancel
```

**Nota:** Usar `https://` (no `http://`)

### 2. Endpoint de Verificación (Opcional)

Si el backend no tiene el endpoint `/donaciones/verify/{sessionId}`, tiene dos opciones:

#### Opción A: Crear el endpoint (Recomendado)

```java
@GetMapping("/verify/{sessionId}")
public ResponseEntity<?> verifyDonation(@PathVariable String sessionId) {
    try {
        // Buscar donación por sessionId en la base de datos
        Donacion donacion = donacionRepository.findByStripeSessionId(sessionId)
            .orElseThrow(() -> new RuntimeException("Donación no encontrada"));
        
        Map<String, Object> response = new HashMap<>();
        response.put("idDonacion", donacion.getIdDonacion());
        response.put("monto", donacion.getAmount());
        response.put("moneda", donacion.getCurrency());
        response.put("fecha", donacion.getFechaCreacion());
        response.put("estado", donacion.getEstado());
        
        return ResponseEntity.ok(response);
    } catch (Exception e) {
        return ResponseEntity.status(404).body(Map.of("error", e.getMessage()));
    }
}
```

#### Opción B: No hacer nada

El frontend ya está configurado para manejar el error 404 y mostrar un mensaje genérico de éxito. Como Stripe redirige a `/donacion/success` solo cuando el pago es exitoso, podemos confiar en eso.

### 3. Multiplicación por 100 para Stripe

**El backend DEBE multiplicar el monto por 100** antes de enviarlo a Stripe.

En el método que crea la sesión de Stripe:

```java
// ❌ INCORRECTO (causa error amount_too_small)
long amount = (long) donacionRequest.getAmount();

// ✅ CORRECTO
long amountInCents = (long) (donacionRequest.getAmount() * 100);

SessionCreateParams params = SessionCreateParams.builder()
    .addPaymentMethodType(SessionCreateParams.PaymentMethodType.CARD)
    .setMode(SessionCreateParams.Mode.PAYMENT)
    .setSuccessUrl(donacionRequest.getSuccessUrl())
    .setCancelUrl(donacionRequest.getCancelUrl())
    .addLineItem(
        SessionCreateParams.LineItem.builder()
            .setPriceData(
                SessionCreateParams.LineItem.PriceData.builder()
                    .setCurrency("usd")
                    .setUnitAmount(amountInCents) // ⬅️ EN CENTAVOS
                    .setProductData(
                        SessionCreateParams.LineItem.PriceData.ProductData.builder()
                            .setName("Donación - Recetas Del Mundo")
                            .build()
                    )
                    .build()
            )
            .setQuantity(1L)
            .build()
    )
    .build();
```

## 🚀 Desplegar Cambios del Frontend

### En tu PC (Windows):

```powershell
cd "f:\Cosas IO\Repositorios\Recetas-Del-Mundo\frontend"

# Build
docker build -t tiopig1324/recetas-frontend:latest .

# Push
docker push tiopig1324/recetas-frontend:latest
```

### En el Servidor:

```bash
cd /home/admin/api-recetas/

# Pull nueva imagen
docker pull tiopig1324/recetas-frontend:latest

# Recrear contenedor
docker compose -f docker-compose.prod.yml up -d --force-recreate frontend

# Ver logs
docker logs recetas-frontend --tail 50
```

## ✅ Checklist de Verificación

### Frontend (Ya corregido)
- [x] URL de cancel actualizada a `/donacion/cancel`
- [x] Ruta en App.js agregada
- [x] Manejo de error 404 en verificación
- [x] Monto cambiado a 50 centavos

### Backend (Pendiente)
- [ ] URL de cancel en .env con `https://`
- [ ] Multiplicar amount por 100 antes de enviar a Stripe
- [ ] Endpoint `/donaciones/verify/{sessionId}` (opcional)
- [ ] Guardar `stripeSessionId` en la tabla donaciones

### Testing
- [ ] Crear donación y verificar que redirige correctamente
- [ ] Probar cancelación y verificar URL correcta
- [ ] Verificar que Stripe recibe el monto en centavos
- [ ] Confirmar que no hay error `amount_too_small`

## 🐛 Debugging

### Si sigue fallando:

1. **Ver logs del backend:**
   ```bash
   docker logs api-recetas-backend --tail 100
   ```

2. **Verificar variable de entorno:**
   ```bash
   docker exec api-recetas-backend env | grep DONATION
   ```

3. **Probar endpoint manualmente:**
   ```bash
   curl -X POST https://recetasdelmundo.site/api/donaciones/create-session \
     -H "Authorization: Bearer TU_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "amount": 50,
       "successUrl": "https://recetasdelmundo.site/donacion/success?session_id={CHECKOUT_SESSION_ID}",
       "cancelUrl": "https://recetasdelmundo.site/donacion/cancel"
     }'
   ```

4. **Ver respuesta de Stripe:**
   - Los logs del backend deben mostrar el error exacto de Stripe
   - Verificar que `amount` sea >= 50 (centavos)

---

**Fecha:** 19 de noviembre de 2025  
**Proyecto:** Recetas Del Mundo  
**Cambios:** Corrección de rutas y montos para donaciones con Stripe
