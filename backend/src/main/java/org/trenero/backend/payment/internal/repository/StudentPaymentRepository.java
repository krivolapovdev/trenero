package org.trenero.backend.payment.internal.repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.trenero.backend.payment.internal.domain.StudentPayment;

@Repository
public interface StudentPaymentRepository
    extends JpaRepository<@NonNull StudentPayment, @NonNull UUID> {
  @Query(
      """
      SELECT sp
      FROM StudentPayment AS sp
      JOIN FETCH sp.transaction AS t
      WHERE t.ownerId = :ownerId
        AND t.deletedAt IS NULL
      """)
  List<StudentPayment> findAllByOwnerId(@Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT sp
      FROM StudentPayment AS sp
      JOIN FETCH sp.transaction AS t
      WHERE sp.studentId = :studentId
        AND t.ownerId = :ownerId
        AND t.deletedAt IS NULL
      """)
  List<StudentPayment> findAllByStudentIdAndOwnerId(
      @Param("studentId") UUID studentId, @Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT sp
      FROM StudentPayment AS sp
      JOIN FETCH sp.transaction AS t
      WHERE t.id = :transactionId
        AND t.ownerId = :ownerId
        AND t.deletedAt IS NULL
      """)
  Optional<StudentPayment> findByTransactionIdAndOwnerId(
      @Param("transactionId") UUID transactionId, @Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT sp
      FROM StudentPayment AS sp
      JOIN FETCH sp.transaction AS t
      WHERE sp.studentId IN :studentIds
        AND t.ownerId = :ownerId
        AND t.deletedAt IS NULL
      """)
  List<StudentPayment> findAllByStudentIdsAndOwnerId(
      @Param("studentIds") List<UUID> studentIds, @Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT sp.paidUntil
      FROM StudentPayment AS sp
      JOIN sp.transaction AS t
      WHERE sp.studentId = :studentId
        AND t.deletedAt IS NULL
      ORDER BY sp.paidUntil DESC
      LIMIT 1
      """)
  Optional<LocalDate> findLatestPaidUntilByStudentId(@Param("studentId") UUID studentId);

  @Query(
      """
      SELECT MAX(sp.paidUntil)
      FROM StudentPayment AS sp
      JOIN sp.transaction AS t
      WHERE sp.studentId = :studentId
        AND sp.paidUntil < :currentPaidUntil
        AND t.deletedAt IS NULL
      """)
  Optional<LocalDate> findLatestPaidUntilBeforeDate(
      @Param("studentId") UUID studentId, @Param("currentPaidUntil") LocalDate currentPaidUntil);

  @Query(
      """
      SELECT sp FROM StudentPayment sp
      JOIN FETCH sp.transaction t
      WHERE sp.studentId = :studentId
        AND t.ownerId = :ownerId
        AND t.deletedAt IS NULL
      ORDER BY sp.paidUntil DESC
      """)
  List<StudentPayment> findAllByStudentIdAndOwnerIdSorted(
      @Param("studentId") UUID studentId, @Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT sp FROM StudentPayment sp
      JOIN FETCH sp.transaction t
      WHERE t.ownerId = :ownerId
        AND t.deletedAt IS NULL
      ORDER BY sp.paidUntil DESC
      """)
  List<StudentPayment> findAllByOwnerIdSorted(@Param("ownerId") UUID ownerId);
}
