package org.trenero.backend.auth.internal.controller

import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import org.trenero.backend.auth.internal.service.ReviewerAuthService
import org.trenero.backend.common.response.LoginResponse

@RestController
@RequestMapping("/api/v1/reviewer")
class ReviewerAuthController(private val reviewerAuthService: ReviewerAuthService) {

  @PostMapping("/login")
  fun login(@RequestHeader("X-Reviewer-Key") incomingKey: String): LoginResponse =
    reviewerAuthService.login(incomingKey)
}
