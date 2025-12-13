package tech.trenero.backend.auth.internal.controller;

import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import tech.trenero.backend.auth.internal.helper.CookieHelper;
import tech.trenero.backend.auth.internal.response.JwtTokenResponse;
import tech.trenero.backend.auth.internal.service.JwtTokenService;

@RestController
@RequestMapping("/api/v1/tokens")
@RequiredArgsConstructor
@Validated
public class JwtTokenController {
  private final JwtTokenService jwtTokenService;

  @PostMapping("/refresh")
  public JwtTokenResponse renewTokens(
      @CookieValue(CookieHelper.REFRESH_TOKEN_COOKIE_NAME) String refreshToken,
      HttpServletResponse response) {
    return jwtTokenService.renewTokens(refreshToken, response);
  }
}
