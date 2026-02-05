package org.trenero.backend.auth.internal.service;

import io.jsonwebtoken.JwtException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.trenero.backend.auth.internal.request.RefreshTokenRequest;
import org.trenero.backend.common.response.JwtTokensResponse;
import org.trenero.backend.common.security.JwtTokenProvider;
import org.trenero.backend.common.security.JwtUser;

@Service
@RequiredArgsConstructor
@Slf4j
public class JwtTokenService {
  private final JwtTokenProvider jwtTokenProvider;

  public JwtTokensResponse createAccessAndRefreshTokens(JwtUser jwtUser) {
    log.info("Creating jwtTokens for user: {}", jwtUser);

    String accessToken = jwtTokenProvider.generateAccessToken(jwtUser);
    String refreshToken = jwtTokenProvider.generateRefreshToken(jwtUser);

    return new JwtTokensResponse(accessToken, refreshToken);
  }

  public JwtTokensResponse refreshTokens(RefreshTokenRequest request) {
    log.info("Refreshing jwtTokens: {}", request);

    String oldRefreshToken = request.refreshToken();

    if (!jwtTokenProvider.isTokenValid(oldRefreshToken)) {
      throw new JwtException("Invalid refresh token");
    }

    JwtUser jwtUser = jwtTokenProvider.extractUser(oldRefreshToken);

    return createAccessAndRefreshTokens(jwtUser);
  }
}
