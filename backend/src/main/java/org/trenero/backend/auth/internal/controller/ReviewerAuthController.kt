package org.trenero.backend.auth.internal.controller

import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import org.trenero.backend.auth.external.response.LoginResponse
import org.trenero.backend.auth.internal.service.ReviewerLoginService

@RestController
@RequestMapping("/api/v1/reviewer")
class ReviewerAuthController(private val reviewerLoginService: ReviewerLoginService) {

  @PostMapping("/login")
  fun login(@RequestHeader("X-Reviewer-Key") reviewerKey: String): LoginResponse =
    reviewerLoginService.login(reviewerKey)
}
