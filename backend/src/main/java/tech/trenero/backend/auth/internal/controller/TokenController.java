package tech.trenero.backend.auth.internal.controller;

import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import tech.trenero.backend.auth.internal.service.TokenService;
import tech.trenero.backend.common.helper.CookieHelper;
import tech.trenero.backend.common.response.JwtTokenResponse;

@RestController
@RequestMapping("/api/v1/tokens")
@RequiredArgsConstructor
@Validated
public class TokenController {
  private final TokenService tokenService;

  @PostMapping("/refresh")
  public JwtTokenResponse renewTokens(
      @CookieValue(CookieHelper.REFRESH_TOKEN_COOKIE_NAME) String refreshToken,
      HttpServletResponse response) {
    return tokenService.renewTokens(refreshToken, response);
  }
}
