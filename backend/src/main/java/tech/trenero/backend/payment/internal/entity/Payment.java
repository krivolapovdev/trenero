package tech.trenero.backend.payment.internal.entity;

import com.github.f4b6a3.uuid.UuidCreator;
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
import org.hibernate.annotations.CreationTimestamp;

@Entity
@Table(name = "payments", schema = "payments_module")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Payment {
  @Id
  @Column(name = "id", updatable = false, nullable = false)
  private UUID id = UuidCreator.getTimeOrderedEpoch();

  @Column(name = "student_id", nullable = false)
  private UUID studentId;

  @Column(name = "amount", nullable = false)
  private BigDecimal amount;

  @CreationTimestamp
  @Column(name = "created_at", nullable = false, updatable = false)
  private LocalDateTime createdAt;
}
