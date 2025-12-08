package tech.trenero.backend.group.internal.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import tech.trenero.backend.group.internal.entity.Group;

@Repository
public interface GroupRepository extends JpaRepository<Group, UUID> {
  @Query(
      """
        SELECT g
        FROM Group g
        WHERE g.ownerId = :ownerId""")
  List<Group> findByOwnerId(@Param("ownerId") UUID ownerId);

  @Query(
      """
        SELECT g
        FROM Group g
        WHERE g.id = :groupId
        AND g.ownerId = :ownerId
    """)
  Optional<Group> findByIdAndOwnerId(
      @Param("groupId") UUID groupId, @Param("ownerId") UUID ownerId);
}
