package tech.trenero.backend.payment.internal.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import tech.trenero.backend.payment.internal.entity.Payment;

@Repository
public interface PaymentRepository extends JpaRepository<@NonNull Payment, @NonNull UUID> {
  @Query(
      """
          SELECT DISTINCT p
          FROM Payment AS p
          WHERE p.ownerId = :ownerId
            AND p.deleted = false
          ORDER BY p.createdAt DESC""")
  List<Payment> findAllByOwnerId(@Param("ownerId") UUID ownerId);

  @Query(
      """
          SELECT DISTINCT p
          FROM Payment AS p
          WHERE p.studentId = :studentId
            AND p.ownerId = :ownerId
            AND p.deleted = false
          ORDER BY p.createdAt DESC""")
  List<Payment> findAllByStudentId(
      @Param("studentId") UUID studentId, @Param("ownerId") UUID ownerId);

  @Query(
      """
          SELECT p
          FROM Payment AS p
          WHERE p.id = :id
            AND p.deleted = false
            AND p.ownerId = :ownerId""")
  Optional<Payment> findByIdAndOwnerId(@Param("id") UUID id, @Param("ownerId") UUID ownerId);
}
