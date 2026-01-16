package tech.trenero.backend.payment.internal.service;

import graphql.schema.DataFetchingEnvironment;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.codegen.types.CreatePaymentInput;
import tech.trenero.backend.codegen.types.UpdatePaymentInput;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.payment.internal.entity.Payment;
import tech.trenero.backend.payment.internal.mapper.PaymentMapper;
import tech.trenero.backend.payment.internal.repository.PaymentRepository;
import tech.trenero.backend.student.external.StudentSpi;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentService {
  private final PaymentRepository paymentRepository;
  private final PaymentMapper paymentMapper;
  @Lazy private final StudentSpi studentSpi;

  @Transactional(readOnly = true)
  public List<tech.trenero.backend.codegen.types.Payment> getAllPayments(JwtUser jwtUser) {
    log.info("Get payments for user {}", jwtUser.userId());
    return paymentRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(paymentMapper::toGraphql)
        .toList();
  }

  @Transactional(readOnly = true)
  public Optional<tech.trenero.backend.codegen.types.Payment> findPaymentById(
      UUID id, JwtUser jwtUser) {
    log.info("Get status of payment with id {}", id);
    return paymentRepository.findByIdAndOwnerId(id, jwtUser.userId()).map(paymentMapper::toGraphql);
  }

  @Transactional(readOnly = true)
  public List<tech.trenero.backend.codegen.types.Payment> getPaymentsByStudentId(
      UUID studentId, JwtUser jwtUser) {
    log.info("Getting payments by studentId={}", studentId);
    return paymentRepository.findAllByStudentId(studentId, jwtUser.userId()).stream()
        .map(paymentMapper::toGraphql)
        .toList();
  }

  @Transactional
  public tech.trenero.backend.codegen.types.Payment createPayment(
      CreatePaymentInput input, JwtUser jwtUser) {
    log.info("Creating payment {}", input);

    studentSpi.getStudentById(input.getStudentId(), jwtUser);

    Payment payment = paymentMapper.toPayment(input, jwtUser.userId());

    Payment savedPayment = savePayment(payment);

    return paymentMapper.toGraphql(savedPayment);
  }

  @Transactional
  public Optional<tech.trenero.backend.codegen.types.Payment> updatePayment(
      UUID id, UpdatePaymentInput input, DataFetchingEnvironment environment, JwtUser jwtUser) {
    log.info("Edit payment {}", input);
    return paymentRepository
        .findByIdAndOwnerId(id, jwtUser.userId())
        .map(pay -> paymentMapper.updatePayment(pay, input, environment))
        .map(this::savePayment)
        .map(paymentMapper::toGraphql);
  }

  @Transactional
  public Optional<tech.trenero.backend.codegen.types.Payment> softDeletePayment(
      UUID id, JwtUser jwtUser) {
    log.info("Deleting payment: {}", id);
    return paymentRepository
        .findByIdAndOwnerId(id, jwtUser.userId())
        .map(
            payment -> {
              payment.setDeletedAt(OffsetDateTime.now());
              return savePayment(payment);
            })
        .map(paymentMapper::toGraphql);
  }

  private Payment savePayment(Payment payment) {
    log.info("Save payment: {}", payment);
    return paymentRepository.saveAndFlush(payment);
  }
}
