package tech.trenero.backend.student.internal.entity;

import com.github.f4b6a3.uuid.UuidCreator;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.NonNull;
import org.hibernate.annotations.CreationTimestamp;

@Entity
@Table(
    name = "students",
    schema = "students_module",
    uniqueConstraints = {@UniqueConstraint(columnNames = {"owner_id", "fullName"})},
    indexes = {
      @Index(columnList = "owner_id, full_name"),
      @Index(columnList = "owner_id, group_id, full_name")
    })
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Student {
  @Id
  @Column(name = "id", updatable = false, nullable = false)
  @Builder.Default
  private UUID id = UuidCreator.getTimeOrderedEpoch();

  @Column(name = "owner_id", nullable = false, updatable = false)
  @NonNull
  private UUID ownerId;

  @Column(name = "full_name", nullable = false)
  @NonNull
  private String fullName;

  @Column(name = "birthdate")
  private LocalDate birthdate;

  @Column(name = "phone")
  private String phone;

  @Column(name = "note")
  private String note;

  @Column(name = "group_id")
  private UUID groupId;

  @CreationTimestamp
  @Column(name = "created_at", nullable = false, updatable = false)
  private OffsetDateTime createdAt;

  @Column(name = "deleted", nullable = false)
  @Builder.Default
  private boolean deleted = false;
}
