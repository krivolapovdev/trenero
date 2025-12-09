package tech.trenero.backend.student.internal.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.jspecify.annotations.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import tech.trenero.backend.student.internal.entity.Student;

@Repository
public interface StudentRepository extends JpaRepository<@NonNull Student, @NonNull UUID> {
  @Query(
      """
          SELECT s
          FROM Student AS s
          WHERE s.id = :studentId
          AND s.ownerId = :ownerId""")
  Optional<Student> findByIdAndOwnerId(
      @Param("studentId") UUID studentId, @Param("ownerId") UUID ownerId);

  @Query(
      """
          SELECT DISTINCT s
          FROM Student AS s
          JOIN StudentGroup sg ON s.id = sg.studentId
          WHERE sg.groupId = :groupId
          AND s.ownerId = :ownerId""")
  List<Student> findAllByGroupIdAndOwnerId(
      @Param("groupId") UUID groupId, @Param("ownerId") UUID ownerId);
}
