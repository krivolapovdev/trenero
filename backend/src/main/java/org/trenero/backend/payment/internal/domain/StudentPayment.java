package org.trenero.backend.payment.internal.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "student_payments", schema = "payments_module")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StudentPayment {
  @Id
  @Column(name = "transaction_id", nullable = false, updatable = false)
  private UUID transactionId;

  @Column(name = "student_id", nullable = false, updatable = false)
  @NotNull
  private UUID studentId;

  @Column(name = "paid_lessons", nullable = false)
  @NotNull
  private Integer paidLessons;

  @OneToOne(fetch = FetchType.LAZY)
  @MapsId
  @JoinColumn(name = "transaction_id")
  private Transaction transaction;
}
