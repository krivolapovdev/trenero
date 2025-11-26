package tech.trenero.backend.group.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.UUID;
import lombok.Data;

@Entity
@Table(name = "groups")
@Data
public class Group {
  @Id
  @Column(name = "id")
  private UUID id;

  @Column(name = "name")
  private String name;
}
