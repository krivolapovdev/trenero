package tech.trenero.backend.metric.internal.service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.domain.TransactionType;
import tech.trenero.backend.common.response.TransactionResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.metric.internal.response.MonthlyPaymentMetricResponse;
import tech.trenero.backend.payment.external.TransactionSpi;

@Service
@Slf4j
@RequiredArgsConstructor
public class MetricService {
  @Lazy private final TransactionSpi transactionSpi;

  @Transactional(readOnly = true)
  public List<MonthlyPaymentMetricResponse> getMonthlyStatistics(JwtUser jwtUser) {
    log.info("Calculating monthly payment statistics for userId={}", jwtUser.userId());

    LocalDate startMonth = LocalDate.now().minusMonths(6);
    LocalDate endMonth = LocalDate.now();

    List<TransactionResponse> transactions = transactionSpi.getAllTransactions(jwtUser);

    Map<LocalDate, BigDecimal> totalByMonth =
        transactions.stream()
            .filter(p -> !p.date().isBefore(startMonth) && !p.date().isAfter(endMonth))
            .collect(
                Collectors.groupingBy(
                    TransactionResponse::date,
                    Collectors.mapping(
                        t -> t.type() == TransactionType.INCOME ? t.amount() : t.amount().negate(),
                        Collectors.reducing(BigDecimal.ZERO, BigDecimal::add))));

    return Stream.iterate(startMonth, m -> !m.isAfter(endMonth), m -> m.plusMonths(1))
        .map(
            month ->
                new MonthlyPaymentMetricResponse(
                    month, totalByMonth.getOrDefault(month, BigDecimal.ZERO)))
        .toList();
  }
}
