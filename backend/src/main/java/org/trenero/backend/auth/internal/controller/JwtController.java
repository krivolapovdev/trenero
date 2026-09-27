package org.trenero.backend.auth.internal.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.trenero.backend.auth.internal.request.RefreshTokenRequest;
import org.trenero.backend.auth.internal.service.JwtService;
import org.trenero.backend.common.response.JwtResponse;

@RestController
@RequestMapping("/api/v1/jwt")
@RequiredArgsConstructor
public class JwtController {
  private final JwtService jwtService;

  @PostMapping("/refresh")
  public JwtResponse refreshTokens(@RequestBody @Valid RefreshTokenRequest request) {
    return jwtService.refreshTokens(request);
  }
}
