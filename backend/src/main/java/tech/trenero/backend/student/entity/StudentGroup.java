package tech.trenero.backend.student.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.UUID;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "student_groups", schema = "students_module")
@Data
@NoArgsConstructor
public class StudentGroup {
  @Id private UUID id = UUID.randomUUID();

  @Column(name = "student_id", nullable = false)
  private UUID studentId;

  @Column(name = "group_id", nullable = false)
  private UUID groupId;

  public StudentGroup(UUID studentId, UUID groupId) {
    this.studentId = studentId;
    this.groupId = groupId;
  }
}
