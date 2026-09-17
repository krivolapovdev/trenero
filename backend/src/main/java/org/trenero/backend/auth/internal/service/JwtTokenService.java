package org.trenero.backend.auth.internal.service;

import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Service;
import org.trenero.backend.auth.internal.request.RefreshTokenRequest;
import org.trenero.backend.common.domain.TokenType;
import org.trenero.backend.common.response.JwtTokensResponse;
import org.trenero.backend.common.security.JwtTokenProvider;
import org.trenero.backend.common.security.JwtUser;

@Service
@RequiredArgsConstructor
@Slf4j
public class JwtTokenService {

  private final JwtTokenProvider jwtTokenProvider;

  public @NonNull JwtTokensResponse createAccessAndRefreshTokens(@NonNull JwtUser jwtUser) {
    log.info("Creating JWT access and refresh tokens for id={}", jwtUser.id());

    var accessToken = jwtTokenProvider.generateAccessToken(jwtUser);
    var refreshToken = jwtTokenProvider.generateRefreshToken(jwtUser);

    return new JwtTokensResponse(accessToken, refreshToken);
  }

  public @NonNull JwtTokensResponse refreshTokens(@NonNull RefreshTokenRequest request) {
    log.info("Processing token refresh request");

    var oldRefreshToken = request.refreshToken();

    if (!jwtTokenProvider.isTokenValid(oldRefreshToken, TokenType.REFRESH)) {
      log.warn("Refresh token validation failed");
      throw new BadCredentialsException("Invalid or expired refresh token");
    }

    var jwtUser = jwtTokenProvider.extractUser(oldRefreshToken);

    return createAccessAndRefreshTokens(jwtUser);
  }
}
