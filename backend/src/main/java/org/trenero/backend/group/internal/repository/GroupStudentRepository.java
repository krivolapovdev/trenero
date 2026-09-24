package org.trenero.backend.group.internal.repository;

import java.util.List;
import java.util.UUID;
import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.trenero.backend.group.internal.domain.GroupStudent;

@Repository
public interface GroupStudentRepository
    extends JpaRepository<@NonNull GroupStudent, @NonNull UUID> {

  @Query(
      """
          SELECT gs
          FROM GroupStudent AS gs
          WHERE gs.ownerId = :ownerId
            AND gs.ownerId = :ownerId
          ORDER BY gs.createdAt DESC
          """)
  List<GroupStudent> findAllByOwnerId(@Param("ownerId") UUID ownerId);

  @Query(
      """
          SELECT gs
          FROM GroupStudent AS gs
          WHERE gs.studentId IN :studentIds
            AND gs.ownerId = :ownerId
          """)
  List<GroupStudent> findAllByStudentIds(@Param("studentIds") List<UUID> studentIds, UUID ownerId);

  @Query(
      """
          SELECT gs
          FROM GroupStudent AS gs
          WHERE gs.groupId IN :groupIds
            AND gs.ownerId = :ownerId
          """)
  List<GroupStudent> findAllByGroupIds(
      @Param("groupIds") List<UUID> groupIds, @Param("ownerId") UUID ownerId);

  @Query(
      """
          SELECT gs
          FROM GroupStudent AS gs
          WHERE gs.groupId = :groupId
            AND gs.ownerId = :ownerId
          """)
  List<GroupStudent> findAllByGroupId(
      @Param("groupId") UUID groupId, @Param("ownerId") UUID ownerId);

  @Query(
      """
          SELECT gs
          FROM GroupStudent AS gs
          WHERE gs.studentId = :studentId
            AND gs.ownerId = :ownerId
          """)
  List<GroupStudent> findAllByStudentId(
      @Param("studentId") UUID studentId, @Param("ownerId") UUID ownerId);

  @Modifying
  @Query(
      """
          DELETE FROM GroupStudent gs
          WHERE gs.groupId = :groupId
            AND gs.ownerId = :ownerId
          """)
  void deleteByGroupId(@Param("groupId") UUID groupId, @Param("ownerId") UUID ownerId);

  @Modifying
  @Query(
      """
          DELETE FROM GroupStudent gs
          WHERE gs.groupId = :groupId
            AND gs.studentId = :studentId
            AND gs.ownerId = :ownerId
          """)
  void deleteByStudentIdAndGroupId(
      @Param("groupId") UUID groupId,
      @Param("studentId") UUID studentId,
      @Param("ownerId") UUID uuid);
}
