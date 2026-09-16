package org.trenero.backend.auth.internal.service;

import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Service;
import org.trenero.backend.auth.internal.config.ReviewerProperties;
import org.trenero.backend.common.domain.OAuth2Provider;
import org.trenero.backend.common.response.LoginResponse;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.user.external.UserSpi;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReviewerAuthService {

  private final JwtTokenService jwtTokenService;
  private final ReviewerProperties reviewerProperties;
  @Lazy private final UserSpi userSpi;

  public boolean isValidKey(@NonNull String key) {
    return reviewerProperties.getKey().equals(key);
  }

  public @NonNull LoginResponse login(@NonNull String incomingKey) {
    log.info("Attempting reviewer authentication");

    if (!isValidKey(incomingKey)) {
      throw new BadCredentialsException("Invalid reviewer key");
    }

    var user =
        userSpi.getOrCreateUserFromOAuth2(
            OAuth2Provider.GOOGLE, "REVIEWER", "REVIEWER@TRENERO.ORG");

    var jwtUser = new JwtUser(user.id(), user.email());
    var tokens = jwtTokenService.createAccessAndRefreshTokens(jwtUser);

    return new LoginResponse(user, tokens);
  }
}
