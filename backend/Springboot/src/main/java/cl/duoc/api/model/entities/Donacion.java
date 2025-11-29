package cl.duoc.api.model.entities;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.math.BigDecimal;

@Entity
@Table(name = "donacion")
public class Donacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idDonacion;

    private Integer idUsr;

    private Integer idReceta;

    @Column(precision = 12, scale = 2)
    private BigDecimal amount; // units, e.g. 5.00

    private String currency;

    private String stripeSessionId;

    private String stripePaymentIntent;

    private String status;

    private LocalDateTime fechaCreacion;

    private LocalDateTime fechaActualizacion;

    @PrePersist
    public void prePersist() {
        if (this.fechaCreacion == null) {
            this.fechaCreacion = LocalDateTime.now();
        }
        this.fechaActualizacion = this.fechaCreacion;
    }

    @PreUpdate
    public void preUpdate() {
        this.fechaActualizacion = LocalDateTime.now();
    }

    // Getters / Setters
    public Integer getIdDonacion() { return idDonacion; }
    public void setIdDonacion(Integer idDonacion) { this.idDonacion = idDonacion; }

    public Integer getIdUsr() { return idUsr; }
    public void setIdUsr(Integer idUsr) { this.idUsr = idUsr; }

    public Integer getIdReceta() { return idReceta; }
    public void setIdReceta(Integer idReceta) { this.idReceta = idReceta; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public String getStripeSessionId() { return stripeSessionId; }
    public void setStripeSessionId(String stripeSessionId) { this.stripeSessionId = stripeSessionId; }

    public String getStripePaymentIntent() { return stripePaymentIntent; }
    public void setStripePaymentIntent(String stripePaymentIntent) { this.stripePaymentIntent = stripePaymentIntent; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(LocalDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }

    public LocalDateTime getFechaActualizacion() { return fechaActualizacion; }
    public void setFechaActualizacion(LocalDateTime fechaActualizacion) { this.fechaActualizacion = fechaActualizacion; }
}
