package tech.trenero.backend.attendance.internal.entity;

import com.github.f4b6a3.uuid.UuidCreator;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
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
    name = "attendance",
    schema = "attendance_module",
    uniqueConstraints = {@UniqueConstraint(columnNames = {"lesson_id", "student_id"})},
    indexes = {
      @Index(columnList = "owner_id, student_id"),
      @Index(columnList = "owner_id, lesson_id, student_id")
    })
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Attendance {
  @Id
  @Column(name = "id", updatable = false, nullable = false)
  @Builder.Default
  private UUID id = UuidCreator.getTimeOrderedEpoch();

  @Column(name = "owner_id", nullable = false, updatable = false)
  @NonNull
  private UUID ownerId;

  @Column(name = "lesson_id", nullable = false, updatable = false)
  @NonNull
  private UUID lessonId;

  @Column(name = "student_id", nullable = false, updatable = false)
  @NonNull
  private UUID studentId;

  @Column(name = "present", nullable = false)
  private boolean present;

  @CreationTimestamp
  @Column(name = "created_at", nullable = false, updatable = false)
  private OffsetDateTime createdAt;

  @Column(name = "deleted", nullable = false)
  @Builder.Default
  private boolean deleted = false;
}
