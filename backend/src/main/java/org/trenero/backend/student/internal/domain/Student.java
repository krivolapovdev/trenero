package org.trenero.backend.student.internal.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

@Entity
@Table(name = "students", schema = "students_module")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Student {

  @Id
  @Column(name = "id", updatable = false, nullable = false)
  @GeneratedValue(strategy = GenerationType.UUID)
  private UUID id;

  @Column(name = "owner_id", nullable = false, updatable = false)
  @NotNull
  private UUID ownerId;

  @Column(name = "full_name", nullable = false)
  @NotNull
  @Size(max = 255)
  private String fullName;

  @Column(name = "birthdate")
  private LocalDate birthdate;

  @Column(name = "phone", length = 15)
  @Size(max = 15)
  private String phone;

  @Column(name = "note", length = 1023)
  @Size(max = 1023)
  private String note;

  /** Whether the student studies for free and is therefore never charged for lessons. */
  @Column(name = "free", nullable = false)
  private boolean free;

  @CreationTimestamp
  @Column(name = "created_at", nullable = false, updatable = false)
  private OffsetDateTime createdAt;

  @UpdateTimestamp
  @Column(name = "updated_at", nullable = false)
  private OffsetDateTime updatedAt;
}
