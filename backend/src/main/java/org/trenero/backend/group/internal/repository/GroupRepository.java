package org.trenero.backend.group.internal.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.trenero.backend.group.internal.domain.Group;

@Repository
public interface GroupRepository extends JpaRepository<@NonNull Group, @NonNull UUID> {
  @Query(
      """
      SELECT g
      FROM Group AS g
      WHERE g.ownerId = :ownerId
        AND g.deletedAt IS NULL
      ORDER BY g.name
      """)
  List<Group> findAllByOwnerId(@Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT g
      FROM Group AS g
      WHERE g.id = :groupId
        AND g.ownerId = :ownerId
        AND g.deletedAt IS NULL
      """)
  Optional<Group> findByIdAndOwnerId(
      @Param("groupId") UUID groupId, @Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT g
      FROM Group g
      WHERE g.ownerId = :ownerId
        AND g.id IN :groupIds
        AND g.deletedAt IS NULL
      """)
  List<Group> findAllByIdsAndOwnerId(
      @Param("groupIds") List<UUID> groupIds, @Param("ownerId") UUID ownerId);
}
