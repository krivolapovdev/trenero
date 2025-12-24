package tech.trenero.backend.lesson.internal.entity;

import com.github.f4b6a3.uuid.UuidCreator;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
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
    name = "lessons",
    schema = "lessons_module",
    indexes = {
      @Index(columnList = "owner_id, group_id"),
      @Index(columnList = "owner_id, created_at"),
    })
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Lesson {
  @Id
  @Column(name = "id", updatable = false, nullable = false)
  @Builder.Default
  private UUID id = UuidCreator.getTimeOrderedEpoch();

  @Column(name = "group_id", nullable = false, updatable = false)
  @NonNull
  private UUID groupId;

  @Column(name = "owner_id", nullable = false, updatable = false)
  @NonNull
  private UUID ownerId;

  @Column(name = "start_date_time", nullable = false)
  @NonNull
  private OffsetDateTime startDateTime;

  @CreationTimestamp
  @Column(name = "created_at", nullable = false, updatable = false)
  private OffsetDateTime createdAt;

  @Column(name = "deleted", nullable = false)
  @Builder.Default
  private boolean deleted = false;
}
