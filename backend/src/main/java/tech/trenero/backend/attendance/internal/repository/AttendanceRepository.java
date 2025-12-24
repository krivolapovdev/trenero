package tech.trenero.backend.attendance.internal.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import tech.trenero.backend.attendance.internal.entity.Attendance;

@Repository
public interface AttendanceRepository extends JpaRepository<@NonNull Attendance, @NonNull UUID> {
  @Query(
      """
        SELECT a
        FROM Attendance AS a
        WHERE a.ownerId = :ownerId
        ORDER BY a.createdAt DESC""")
  List<Attendance> findAllByOwnerId(@Param("ownerId") UUID ownerId);

  @Query(
      """
        SELECT a
        FROM Attendance AS a
        WHERE a.id = :attendanceId
          AND a.ownerId = :ownerId""")
  Optional<Attendance> findByIdAndOwnerId(
      @Param("attendanceId") UUID attendanceId, @Param("ownerId") UUID ownerId);

  @Query(
      """
        SELECT a
        FROM Attendance AS a
        WHERE a.studentId = :studentId
          AND a.ownerId = :ownerId""")
  List<Attendance> findAllByStudentIdAndOwnerId(
      @Param("studentId") UUID studentId, @Param("ownerId") UUID ownerId);

  @Query(
      """
        SELECT a
        FROM Attendance AS a
        WHERE a.lessonId = :lessonId
          AND a.ownerId = :ownerId""")
  List<Attendance> findAllByLessonIdAndOwnerId(
      @Param("lessonId") UUID lessonId, @Param("ownerId") UUID ownerId);
}
