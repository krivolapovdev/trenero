package tech.trenero.backend.payment.internal.repository;

import java.util.List;
import java.util.UUID;
import org.jspecify.annotations.NonNull;
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
        WHERE p.studentId = :studentId""")
  List<Payment> findAllByStudentId(@Param("studentId") UUID studentId);
}
