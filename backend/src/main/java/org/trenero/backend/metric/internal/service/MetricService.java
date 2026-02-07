package org.trenero.backend.metric.internal.service;

import java.math.BigDecimal;
import java.time.YearMonth;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.trenero.backend.common.domain.TransactionType;
import org.trenero.backend.common.response.TransactionResponse;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.metric.internal.response.MonthlyPaymentMetricResponse;
import org.trenero.backend.payment.external.TransactionSpi;

@Service
@Slf4j
@RequiredArgsConstructor
public class MetricService {
  @Lazy private final TransactionSpi transactionSpi;

  @Transactional(readOnly = true)
  public List<MonthlyPaymentMetricResponse> getMonthlyStatistics(JwtUser jwtUser) {
    log.info("Calculating monthly payment statistics: user={}", jwtUser);

    YearMonth endMonth = YearMonth.now();
    YearMonth startMonth = endMonth.minusMonths(6);

    List<TransactionResponse> transactionsByDateRange =
        transactionSpi.getTransactionsByDateRange(
            startMonth.atDay(1), endMonth.atEndOfMonth(), jwtUser);

    Map<YearMonth, BigDecimal> totalByMonth =
        transactionsByDateRange.stream()
            .collect(
                Collectors.toMap(
                    tr -> YearMonth.from(tr.date()),
                    tr -> tr.type() == TransactionType.INCOME ? tr.amount() : tr.amount().negate(),
                    BigDecimal::add));

    return Stream.iterate(startMonth, m -> !m.isAfter(endMonth), m -> m.plusMonths(1))
        .map(
            month ->
                new MonthlyPaymentMetricResponse(
                    month, totalByMonth.getOrDefault(month, BigDecimal.ZERO)))
        .toList();
  }
}
