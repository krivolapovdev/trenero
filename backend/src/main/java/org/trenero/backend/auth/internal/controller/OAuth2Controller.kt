package org.trenero.backend.auth.internal.controller

import jakarta.validation.Valid
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import org.trenero.backend.auth.internal.request.OAuth2LoginRequest
import org.trenero.backend.auth.internal.service.OAuth2Service
import org.trenero.backend.common.response.LoginResponse

@RestController
@RequestMapping("/api/v1/oauth2")
class OAuth2Controller(private val oAuth2Service: OAuth2Service) {

  @PostMapping("/google")
  fun googleLogin(@RequestBody @Valid request: OAuth2LoginRequest): LoginResponse =
    oAuth2Service.googleLogin(request)

  @PostMapping("/apple")
  fun appleLogin(@RequestBody @Valid request: OAuth2LoginRequest): LoginResponse =
    oAuth2Service.appleLogin(request)
}
