package tech.trenero.backend.group.internal.entity;

import com.github.f4b6a3.uuid.UuidCreator;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "groups", schema = "groups_module")
@Data
@NoArgsConstructor
public class Group {
  @Id
  @Column(name = "id", updatable = false, nullable = false)
  private UUID id = UuidCreator.getTimeOrderedEpoch();

  @Column(name = "owner_id", nullable = false)
  private UUID ownerId;

  @Column(name = "name", nullable = false, unique = true)
  private String name;

  @Column(name = "default_price")
  private BigDecimal defaultPrice;

  @ElementCollection
  @CollectionTable(
      name = "group_students",
      schema = "groups_module",
      joinColumns = @JoinColumn(name = "group_id"))
  @Column(name = "student_id")
  private List<UUID> studentIds = new ArrayList<>();
}
