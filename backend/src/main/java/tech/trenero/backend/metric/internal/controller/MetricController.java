package tech.trenero.backend.metric.internal.controller;

import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.metric.internal.response.MonthlyPaymentMetricResponse;
import tech.trenero.backend.metric.internal.service.MetricService;

@RestController
@RequestMapping("/api/v1/metrics")
@RequiredArgsConstructor
@Validated
public class MetricController {
  private final MetricService metricService;

  @GetMapping("/payments/monthly")
  @PreAuthorize("isAuthenticated()")
  public List<MonthlyPaymentMetricResponse> getMonthlyPaymentStatistics(
      @AuthenticationPrincipal JwtUser jwtUser) {
    return metricService.getMonthlyStatistics(jwtUser);
  }
}
