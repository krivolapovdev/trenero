package tech.trenero.backend.auth.internal.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.stereotype.Controller;
import org.springframework.validation.annotation.Validated;
import tech.trenero.backend.auth.internal.dto.JwtTokens;
import tech.trenero.backend.auth.internal.input.RefreshTokenInput;
import tech.trenero.backend.auth.internal.service.JwtTokenService;

@Controller
@RequiredArgsConstructor
@Validated
public class JwtTokenController {
  private final JwtTokenService jwtTokenService;

  @MutationMapping
  public JwtTokens refreshTokens(@Argument("input") @Valid RefreshTokenInput input) {
    return jwtTokenService.refreshTokens(input);
  }
}
