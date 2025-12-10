package tech.trenero.backend.group.internal.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.jspecify.annotations.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import tech.trenero.backend.group.internal.entity.Group;

@Repository
public interface GroupRepository extends JpaRepository<@NonNull Group, @NonNull UUID> {
  @Query(
      """
        SELECT DISTINCT g
        FROM Group AS g
        WHERE g.ownerId = :ownerId""")
  List<Group> findByOwnerId(@Param("ownerId") UUID ownerId);

  @Query(
      """
          SELECT g
          FROM Group AS g
          LEFT JOIN FETCH g.studentIds
          WHERE g.id = :groupId
            AND g.ownerId = :ownerId""")
  Optional<Group> findByIdAndOwnerId(
      @Param("groupId") UUID groupId, @Param("ownerId") UUID ownerId);

  @Query(
      """
          SELECT DISTINCT g
          FROM Group AS g
          WHERE g.id IN :groupIds
            AND g.ownerId = :ownerId""")
  List<Group> findAllByIdAndOwnerId(
      @Param("groupIds") List<UUID> groupIds, @Param("ownerId") UUID ownerId);

  @Query(
      """
        SELECT DISTINCT g
        FROM Group AS g
        JOIN g.studentIds AS s
        WHERE s = :studentId
          AND g.ownerId = :ownerId""")
  List<Group> findGroupsByStudentIdAndOwnerId(
      @Param("studentId") UUID studentId, @Param("ownerId") UUID ownerId);
}
