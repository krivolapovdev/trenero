package tech.trenero.backend.metric.internal.service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.response.StudentPaymentResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.metric.internal.response.MonthlyPaymentMetricResponse;
import tech.trenero.backend.payment.external.StudentPaymentSpi;

@Service
@Slf4j
@RequiredArgsConstructor
public class MetricService {
  @Lazy private final StudentPaymentSpi studentPaymentSpi;

  @Transactional(readOnly = true)
  public List<MonthlyPaymentMetricResponse> getMonthlyStatistics(JwtUser jwtUser) {
    log.info("Calculating monthly payment statistics for userId={}", jwtUser.userId());

    List<StudentPaymentResponse> payments = studentPaymentSpi.getAllPayments(jwtUser);

    LocalDate fromMonth = LocalDate.now().minusMonths(6);
    LocalDate toMonth = LocalDate.now();

    Map<LocalDate, BigDecimal> totalByMonth =
        payments.stream()
            .filter(p -> !p.date().isBefore(fromMonth) && !p.date().isAfter(toMonth))
            .collect(
                Collectors.groupingBy(
                    StudentPaymentResponse::date,
                    Collectors.reducing(
                        BigDecimal.ZERO, StudentPaymentResponse::amount, BigDecimal::add)));

    return IntStream.rangeClosed(0, 5)
        .mapToObj(i -> toMonth.minusMonths(5L - i))
        .map(
            month ->
                new MonthlyPaymentMetricResponse(
                    month, totalByMonth.getOrDefault(month, BigDecimal.ZERO)))
        .toList();
  }
}
