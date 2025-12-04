package tech.trenero.backend.auth.internal.service;

import io.jsonwebtoken.JwtException;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import tech.trenero.backend.common.helper.TokenHelper;
import tech.trenero.backend.common.response.AccessTokenResponse;
import tech.trenero.backend.common.security.JwtTokenProvider;

@Service
@RequiredArgsConstructor
@Slf4j
public class TokenService {
  private final JwtTokenProvider jwtTokenProvider;
  private final TokenHelper tokenHelper;

  public AccessTokenResponse refreshToken(
      String oldRefreshTokenCookie, HttpServletResponse response) {
    log.info("Refreshing token: {}", oldRefreshTokenCookie);

    if (!jwtTokenProvider.isTokenValid(oldRefreshTokenCookie)) {
      throw new JwtException("Invalid refresh token");
    }

    String email = jwtTokenProvider.extractEmail(oldRefreshTokenCookie);

    return tokenHelper.generateTokens(email, response);
  }
}
