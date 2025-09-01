package cl.duoc.api.model.entities;

import lombok.Data;

import javax.persistence.*;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "pago")
public class Pago {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_pago")
    private Integer id_pago;

    @Basic
    @Column(name = "order_id")
    private String order_id;

    @Basic
    @Column(name = "amount")
    private Integer amount;

    @Basic
    @Column(name = "status")
    private String status;

    @Basic
    @Column(name = "flow_token")
    private String flow_token;

    @Basic
    @Column(name = "fecha_creacion")
    private LocalDateTime fecha_creacion;

    @Basic
    @Column(name = "id_usr")
    private Integer id_usr;
}
