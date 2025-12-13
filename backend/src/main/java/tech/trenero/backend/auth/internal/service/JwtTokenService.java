package tech.trenero.backend.auth.internal.service;

import io.jsonwebtoken.JwtException;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Service;
import tech.trenero.backend.auth.internal.helper.CookieHelper;
import tech.trenero.backend.auth.internal.helper.JwtTokenHelper;
import tech.trenero.backend.auth.internal.response.JwtTokenResponse;
import tech.trenero.backend.common.security.JwtTokenProvider;
import tech.trenero.backend.common.security.JwtUser;

@Service
@RequiredArgsConstructor
@Slf4j
public class JwtTokenService {
  private final JwtTokenProvider jwtTokenProvider;
  private final JwtTokenHelper jwtTokenHelper;

  public JwtTokenResponse createAccessAndRefreshTokens(
      JwtUser jwtUser, HttpServletResponse response) {
    log.info("Creating tokens for user: {}", jwtUser);
    return jwtTokenHelper.createAccessAndRefreshTokens(jwtUser, response);
  }

  public JwtTokenResponse renewTokens(String oldRefreshTokenCookie, HttpServletResponse response) {
    log.info("Refreshing token: {}", oldRefreshTokenCookie);

    if (!jwtTokenProvider.isTokenValid(oldRefreshTokenCookie)) {
      throw new JwtException("Invalid refresh token");
    }

    JwtUser jwtUser = jwtTokenProvider.extractUser(oldRefreshTokenCookie);

    return jwtTokenHelper.createAccessAndRefreshTokens(jwtUser, response);
  }

  public void revokeRefreshToken(HttpServletResponse response) {
    String expiredRefreshTokenCookie =
        CookieHelper.generateExpiredCookie(CookieHelper.REFRESH_TOKEN_COOKIE_NAME);
    response.addHeader(HttpHeaders.SET_COOKIE, expiredRefreshTokenCookie);
  }
}
