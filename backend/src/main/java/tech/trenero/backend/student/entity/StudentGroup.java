package tech.trenero.backend.student.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import java.io.Serializable;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "student_groups", schema = "students_module")
@Data
@NoArgsConstructor
@AllArgsConstructor
@IdClass(StudentGroup.StudentGroupId.class)
public class StudentGroup {
  @Id
  @Column(name = "student_id", nullable = false)
  private UUID studentId;

  @Id
  @Column(name = "group_id", nullable = false)
  private UUID groupId;

  @Data
  @NoArgsConstructor
  @AllArgsConstructor
  public static class StudentGroupId implements Serializable {
    private UUID studentId;
    private UUID groupId;
  }
}
