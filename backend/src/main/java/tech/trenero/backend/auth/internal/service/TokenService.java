package tech.trenero.backend.auth.internal.service;

import io.jsonwebtoken.JwtException;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import tech.trenero.backend.common.helper.TokenHelper;
import tech.trenero.backend.common.response.JwtTokenResponse;
import tech.trenero.backend.common.security.JwtTokenProvider;
import tech.trenero.backend.common.security.JwtUser;

@Service
@RequiredArgsConstructor
@Slf4j
public class TokenService {
  private final JwtTokenProvider jwtTokenProvider;
  private final TokenHelper tokenHelper;

  public JwtTokenResponse renewTokens(String oldRefreshTokenCookie, HttpServletResponse response) {
    log.info("Refreshing token: {}", oldRefreshTokenCookie);

    if (!jwtTokenProvider.isTokenValid(oldRefreshTokenCookie)) {
      throw new JwtException("Invalid refresh token");
    }

    JwtUser jwtUser = jwtTokenProvider.extractUser(oldRefreshTokenCookie);

    return tokenHelper.createAccessAndRefreshTokens(jwtUser, response);
  }
}
