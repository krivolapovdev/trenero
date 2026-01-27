package tech.trenero.backend.auth.internal.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import tech.trenero.backend.auth.internal.request.RefreshTokenRequest;
import tech.trenero.backend.auth.internal.service.JwtTokenService;
import tech.trenero.backend.common.response.JwtTokensResponse;

@RestController
@RequestMapping("/api/v1/jwt")
@RequiredArgsConstructor
@Validated
public class JwtTokenController {
  private final JwtTokenService jwtTokenService;

  @PostMapping("/refresh")
  public JwtTokensResponse refreshTokens(@RequestBody @Valid RefreshTokenRequest request) {
    return jwtTokenService.refreshTokens(request);
  }
}
