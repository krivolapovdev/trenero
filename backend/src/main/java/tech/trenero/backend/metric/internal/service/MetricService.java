package tech.trenero.backend.metric.internal.service;

import java.math.BigDecimal;
import java.time.YearMonth;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.response.PaymentResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.metric.internal.response.MonthlyPaymentMetricResponse;
import tech.trenero.backend.payment.external.PaymentSpi;

@Service
@Slf4j
@RequiredArgsConstructor
public class MetricService {
  @Lazy private final PaymentSpi paymentSpi;

  @Transactional(readOnly = true)
  public List<MonthlyPaymentMetricResponse> getMonthlyStatistics(JwtUser jwtUser) {
    log.info("Calculating monthly payment statistics for userId={}", jwtUser.userId());

    List<PaymentResponse> payments = paymentSpi.getAllPayments(jwtUser);

    YearMonth fromMonth = YearMonth.now().minusMonths(6);
    YearMonth toMonth = YearMonth.now();

    Map<YearMonth, BigDecimal> totalByMonth =
        payments.stream()
            .filter(
                p -> {
                  YearMonth paymentMonth = YearMonth.from(p.date());
                  return !paymentMonth.isBefore(fromMonth) && !paymentMonth.isAfter(toMonth);
                })
            .collect(
                Collectors.groupingBy(
                    payment -> YearMonth.from(payment.date()),
                    Collectors.reducing(
                        BigDecimal.ZERO, PaymentResponse::amount, BigDecimal::add)));

    return IntStream.rangeClosed(0, 5)
        .mapToObj(i -> toMonth.minusMonths(5L - i))
        .map(
            month ->
                new MonthlyPaymentMetricResponse(
                    month, totalByMonth.getOrDefault(month, BigDecimal.ZERO)))
        .toList();
  }
}
