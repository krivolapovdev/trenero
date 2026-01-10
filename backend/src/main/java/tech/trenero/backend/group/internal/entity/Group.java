package tech.trenero.backend.group.internal.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import java.math.BigDecimal;
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
    name = "groups",
    schema = "groups_module",
    uniqueConstraints = {@UniqueConstraint(columnNames = {"owner_id", "name"})},
    indexes = {
      @Index(columnList = "owner_id, name"),
    })
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Group {
  @Id
  @Column(name = "id", updatable = false, nullable = false)
  @GeneratedValue(strategy = GenerationType.UUID)
  private UUID id;

  @Column(name = "owner_id", nullable = false, updatable = false)
  @NonNull
  private UUID ownerId;

  @Column(name = "name", nullable = false)
  @NonNull
  private String name;

  @Column(name = "default_price")
  private BigDecimal defaultPrice;

  @Column(name = "note")
  private String note;

  @CreationTimestamp
  @Column(name = "created_at", nullable = false, updatable = false)
  private OffsetDateTime createdAt;

  @UpdateTimestamp
  @Column(name = "updated_at", nullable = false)
  private OffsetDateTime updatedAt;

  @Column(name = "deleted_at")
  private OffsetDateTime deletedAt;
}
