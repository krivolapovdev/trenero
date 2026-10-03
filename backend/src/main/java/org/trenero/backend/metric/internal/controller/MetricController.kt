package org.trenero.backend.metric.internal.controller

import java.time.LocalDate
import org.springframework.format.annotation.DateTimeFormat
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.metric.internal.domain.MetricScope
import org.trenero.backend.metric.internal.response.PaymentMetricResponse
import org.trenero.backend.metric.internal.service.MetricService

@RestController
@RequestMapping("/api/v1/metrics")
class MetricController(private val metricService: MetricService) {

  @GetMapping("/payments")
  @PreAuthorize("isAuthenticated()")
  fun getPaymentStatistics(
    @RequestParam(defaultValue = "MONTH") scope: MetricScope,
    @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) startDate: LocalDate,
    @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) endDate: LocalDate,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): List<PaymentMetricResponse> {
    return metricService.getPaymentStatistics(scope, startDate, endDate, jwtUser)
  }
}
