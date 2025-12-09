package tech.trenero.backend.student.internal.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "students", schema = "students_module")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Student {
  @Id
  @Column(name = "id")
  private UUID id = UUID.randomUUID();

  @Column(name = "owner_id", nullable = false)
  private UUID ownerId;

  @Column(name = "full_name", nullable = false)
  private String fullName;

  @Column(name = "birth_date")
  private LocalDate birthDate;

  @Column(name = "phone")
  private String phone;

  @Column(name = "note")
  private String note;

  @Column(name = "deleted")
  private boolean deleted = false;
}
