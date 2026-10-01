package org.trenero.backend.payment.internal.repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.NonNull;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.trenero.backend.payment.internal.domain.Transaction;

@Repository
public interface TransactionRepository extends JpaRepository<@NonNull Transaction, @NonNull UUID> {

  @Query(
      """
          SELECT t
          FROM Transaction AS t
          WHERE t.ownerId = :ownerId
          ORDER BY t.date DESC
          """)
  List<Transaction> findAllByOwnerId(@Param("ownerId") UUID ownerId);

  @Query(
      """
          SELECT t
          FROM Transaction AS t
          WHERE t.ownerId = :ownerId
          """)
  Page<Transaction> findAllByOwnerId(@Param("ownerId") UUID ownerId, Pageable pageable);

  @Query(
      value =
          """
              SELECT t
              FROM Transaction AS t
              LEFT JOIN FETCH t.studentPayment
              WHERE t.ownerId = :ownerId
              ORDER BY t.date DESC, t.createdAt DESC
              """,
      countQuery = "SELECT COUNT(t) FROM Transaction t")
  Page<Transaction> findAllWithStudentPayment(@Param("ownerId") UUID ownerId, Pageable pageable);

  @Query(
      """
          SELECT t
          FROM Transaction AS t
          WHERE t.id = :transactionId
            AND t.ownerId = :ownerId
          """)
  Optional<Transaction> findByIdAndOwnerId(
      @Param("transactionId") UUID transactionId, @Param("ownerId") UUID ownerId);

  @Query(
      """
          SELECT t
          FROM Transaction AS t
          WHERE t.ownerId = :ownerId
            AND t.date BETWEEN :startDate AND :endDate
          ORDER BY t.date DESC
          """)
  List<Transaction> findAllByOwnerIdAndDateBetween(
      @Param("ownerId") UUID ownerId,
      @Param("startDate") LocalDate startDate,
      @Param("endDate") LocalDate endDate);
}
