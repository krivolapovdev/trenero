package tech.trenero.backend.group.internal.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

@Entity
@Table(name = "group_students", schema = "groups_module")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GroupStudent {
  @Id
  @Column(name = "id", nullable = false, updatable = false)
  @GeneratedValue(strategy = GenerationType.UUID)
  private UUID id;

  @Column(name = "owner_id", nullable = false, updatable = false)
  private UUID ownerId;

  @Column(name = "group_id", nullable = false, updatable = false)
  private UUID groupId;

  @Column(name = "student_id", nullable = false, updatable = false)
  private UUID studentId;

  @Column(name = "joined_at", nullable = false)
  private OffsetDateTime joinedAt;

  @Column(name = "left_at")
  private OffsetDateTime leftAt;

  @CreationTimestamp
  @Column(name = "created_at", nullable = false, updatable = false)
  private OffsetDateTime createdAt;

  @UpdateTimestamp
  @Column(name = "updated_at", nullable = false)
  private OffsetDateTime updatedAt;

  @Column(name = "deleted_at")
  private OffsetDateTime deletedAt;
}
