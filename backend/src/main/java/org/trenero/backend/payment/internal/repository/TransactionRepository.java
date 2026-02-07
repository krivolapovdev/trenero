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
import org.trenero.backend.payment.internal.domain.Transaction;

@Repository
public interface TransactionRepository extends JpaRepository<@NonNull Transaction, @NonNull UUID> {
  @Query(
      """
      SELECT t
      FROM Transaction AS t
      WHERE t.ownerId = :ownerId
        AND t.deletedAt IS NULL
      ORDER BY t.date DESC
      """)
  List<Transaction> findAllByOwnerId(@Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT t
      FROM Transaction t
      WHERE t.id = :transactionId
        AND t.ownerId = :ownerId
        AND t.deletedAt IS NULL
      """)
  Optional<Transaction> findByIdAndOwnerId(
      @Param("transactionId") UUID transactionId, @Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT t
      FROM Transaction t
      WHERE t.id IN :ids
        AND t.ownerId = :ownerId
        AND t.deletedAt IS NULL
      """)
  List<Transaction> findAllByIdInAndOwnerId(
      @Param("ids") List<UUID> ids, @Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT t
      FROM Transaction AS t
      WHERE t.ownerId = :ownerId
        AND t.date BETWEEN :startDate AND :endDate
        AND t.deletedAt IS NULL
      ORDER BY t.date DESC
      """)
  List<Transaction> findAllByOwnerIdAndDateBetween(
      @Param("ownerId") UUID ownerId,
      @Param("startDate") LocalDate startDate,
      @Param("endDate") LocalDate endDate);
}
