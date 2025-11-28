package tech.trenero.backend.student.repository;

import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import tech.trenero.backend.student.entity.Student;

@Repository
public interface StudentRepository extends JpaRepository<Student, UUID> {
  @Query(
      value =
          """
            SELECT s.*
            FROM students_module.students s
            INNER JOIN students_module.student_groups sg
            ON s.id = sg.student_id
            WHERE sg.group_id = :groupId""",
      nativeQuery = true)
  List<Student> getStudentsByGroupId(UUID groupId);
}
