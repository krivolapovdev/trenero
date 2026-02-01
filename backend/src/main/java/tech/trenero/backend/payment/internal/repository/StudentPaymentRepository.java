package tech.trenero.backend.payment.internal.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import tech.trenero.backend.payment.internal.domain.StudentPayment;

@Repository
public interface StudentPaymentRepository
    extends JpaRepository<@NonNull StudentPayment, @NonNull UUID> {
  @Query(
      """
      SELECT sp
      FROM StudentPayment sp
      WHERE sp.studentId IN :studentIds
      """)
  List<StudentPayment> findAllByStudentIds(@Param("studentIds") List<UUID> studentIds);

  @Query(
      """
      SELECT sp
      FROM StudentPayment sp
      WHERE sp.transactionId IN :transactionIds
      """)
  List<StudentPayment> findAllByTransactionIds(@Param("transactionIds") List<UUID> transactionIds);

  @Query(
      """
      SELECT sp
      FROM StudentPayment sp
      WHERE sp.studentId = :studentId
      """)
  List<StudentPayment> findAllByStudentId(@Param("studentId") UUID studentId);

  @Query(
      """
      SELECT sp
      FROM StudentPayment AS sp
      JOIN Transaction AS t
      ON t.id = sp.transactionId
      WHERE t.id = :transactionId
        AND t.ownerId = :ownerId
        AND t.deletedAt IS NULL
      """)
  Optional<StudentPayment> findByTransactionIdAndTransactionOwnerId(
      @Param("transactionId") UUID transactionId, @Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT sp
      FROM StudentPayment AS sp
      JOIN Transaction AS t
      ON t.id = sp.transactionId
      WHERE t.ownerId = :ownerId
        AND sp.studentId IN :studentIds
        AND t.deletedAt IS NULL
      ORDER BY t.createdAt DESC
      """)
  List<StudentPayment> findAllByStudentIdsAndTransactionOwnerId(
      @Param("studentIds") List<UUID> studentIds, @Param("ownerId") UUID ownerId);
}
