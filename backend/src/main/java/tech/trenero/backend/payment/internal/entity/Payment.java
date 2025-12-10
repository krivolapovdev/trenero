package tech.trenero.backend.payment.internal.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "payments", schema = "payments_module")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Payment {
  @Id
  @Column(name = "id")
  private UUID id = UUID.randomUUID();

  @Column(name = "student_id", nullable = false)
  private UUID studentId;

  @Column(name = "amount", nullable = false)
  private BigDecimal amount;

  @Column(name = "created_at", nullable = false)
  private LocalDateTime createdAt = LocalDateTime.now();
}
