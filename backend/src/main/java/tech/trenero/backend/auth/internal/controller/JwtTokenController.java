package tech.trenero.backend.auth.internal.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.stereotype.Controller;
import org.springframework.validation.annotation.Validated;
import tech.trenero.backend.auth.internal.service.JwtTokenService;
import tech.trenero.backend.codegen.types.JwtTokens;
import tech.trenero.backend.codegen.types.RefreshTokenInput;

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
