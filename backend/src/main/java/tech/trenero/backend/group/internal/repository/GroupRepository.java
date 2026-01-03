package tech.trenero.backend.group.internal.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.graphql.data.GraphQlRepository;
import tech.trenero.backend.group.internal.entity.Group;

@GraphQlRepository
public interface GroupRepository extends JpaRepository<@NonNull Group, @NonNull UUID> {
  @Query(
      """
        SELECT DISTINCT g
        FROM Group AS g
        WHERE g.ownerId = :ownerId
          AND g.deleted = false
        ORDER BY g.name""")
  List<Group> findAllByOwnerId(@Param("ownerId") UUID ownerId);

  @Query(
      """
          SELECT g
          FROM Group AS g
          WHERE g.id = :groupId
            AND g.ownerId = :ownerId""")
  Optional<Group> findByIdAndOwnerId(
      @Param("groupId") UUID groupId, @Param("ownerId") UUID ownerId);
}
