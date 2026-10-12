package org.trenero.backend.auth.internal.controller

import jakarta.validation.Valid
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import org.trenero.backend.auth.external.response.LoginResponse
import org.trenero.backend.auth.internal.request.OAuth2LoginRequest
import org.trenero.backend.auth.internal.service.GoogleLoginService

@RestController
@RequestMapping("/api/v1/oauth2")
class OAuth2Controller(private val googleLoginService: GoogleLoginService) {

  @PostMapping("/google")
  fun googleLogin(@RequestBody @Valid request: OAuth2LoginRequest): LoginResponse =
    googleLoginService.login(request.token)
}
