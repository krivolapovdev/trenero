package org.trenero.backend.auth.internal.controller

import jakarta.validation.Valid
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import org.trenero.backend.auth.internal.request.RefreshTokenRequest
import org.trenero.backend.auth.internal.service.JwtService
import org.trenero.backend.common.response.JwtResponse

@RestController
@RequestMapping("/api/v1/jwt")
class JwtController(private val jwtService: JwtService) {

  @PostMapping("/refresh")
  fun refreshTokens(@RequestBody @Valid request: RefreshTokenRequest): JwtResponse =
    jwtService.refreshTokens(request)
}
