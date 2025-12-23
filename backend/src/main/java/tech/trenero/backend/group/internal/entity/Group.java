package tech.trenero.backend.group.internal.entity;

import com.github.f4b6a3.uuid.UuidCreator;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
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

@Entity
@Table(
    name = "groups",
    schema = "groups_module",
    uniqueConstraints = {@UniqueConstraint(columnNames = {"owner_id", "name"})})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Group {
  @Id
  @Column(name = "id", updatable = false, nullable = false)
  @Builder.Default
  private UUID id = UuidCreator.getTimeOrderedEpoch();

  @Column(name = "owner_id", nullable = false, updatable = false)
  @NonNull
  private UUID ownerId;

  @Column(name = "name", nullable = false)
  @NonNull
  private String name;

  @Column(name = "default_price")
  private BigDecimal defaultPrice;

  @CreationTimestamp
  @Column(name = "created_at", nullable = false, updatable = false)
  private OffsetDateTime createdAt;

  @Column(name = "deleted")
  @Builder.Default
  private boolean deleted = false;
}
