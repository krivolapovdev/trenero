package tech.trenero.backend.group.internal.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.UUID;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "groups", schema = "groups_module")
@Data
@NoArgsConstructor
public class Group {
  @Id
  @Column(name = "id")
  private UUID id = UUID.randomUUID();

  @Column(name = "name", nullable = false)
  private String name;

  @Column(name = "owner_id", nullable = false)
  private UUID ownerId;
}
