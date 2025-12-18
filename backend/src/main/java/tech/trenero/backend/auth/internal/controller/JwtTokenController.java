package tech.trenero.backend.auth.internal.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import tech.trenero.backend.auth.internal.request.RefreshTokenRequest;
import tech.trenero.backend.auth.internal.response.JwtTokenResponse;
import tech.trenero.backend.auth.internal.service.JwtTokenService;

@RestController
@RequestMapping("/api/v1/tokens")
@RequiredArgsConstructor
@Validated
public class JwtTokenController {
  private final JwtTokenService jwtTokenService;

  @PostMapping("/refresh")
  public JwtTokenResponse renewTokens(@RequestBody RefreshTokenRequest request) {
    return jwtTokenService.renewTokens(request);
  }
}
