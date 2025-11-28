package tech.trenero.backend.student.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.util.UUID;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "students", schema = "students_module")
@Data
@NoArgsConstructor
public class Student {
  @Id
  @Column(name = "id")
  private UUID id = UUID.randomUUID();

  @Column(name = "full_name", nullable = false)
  private String fullName;

  @Column(name = "birth_date")
  private LocalDate birthDate;

  @Column(name = "phone")
  private String phone;

  @Column(name = "note")
  private String note;
}
