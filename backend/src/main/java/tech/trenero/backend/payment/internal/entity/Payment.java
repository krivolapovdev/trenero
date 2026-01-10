package tech.trenero.backend.payment.internal.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.NonNull;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

@Entity
@Table(
    name = "payments",
    schema = "payments_module",
    indexes = {@Index(columnList = "owner_id, student_id, created_at")})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Payment {
  @Id
  @Column(name = "id", updatable = false, nullable = false)
  @GeneratedValue(strategy = GenerationType.UUID)
  private UUID id;

  @Column(name = "owner_id", nullable = false, updatable = false)
  @NonNull
  private UUID ownerId;

  @Column(name = "student_id", nullable = false, updatable = false)
  @NonNull
  private UUID studentId;

  @Column(name = "amount", nullable = false)
  @NonNull
  private BigDecimal amount;

  @Column(name = "lessons_per_payment", nullable = false)
  @NonNull
  private Integer lessonsPerPayment;

  @Column(name = "date", nullable = false)
  @NonNull
  private LocalDate date;

  @CreationTimestamp
  @Column(name = "created_at", nullable = false, updatable = false)
  private OffsetDateTime createdAt;

  @UpdateTimestamp
  @Column(name = "updated_at", nullable = false)
  private OffsetDateTime updatedAt;

  @Column(name = "deleted_at")
  private OffsetDateTime deletedAt;
}
