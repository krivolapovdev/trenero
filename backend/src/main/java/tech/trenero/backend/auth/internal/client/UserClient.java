package tech.trenero.backend.auth.internal.client;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.enums.OAuth2Provider;
import tech.trenero.backend.common.response.UserResponse;
import tech.trenero.backend.user.external.UserSpi;

@Component
@RequiredArgsConstructor
public class UserClient {
  @Lazy private final UserSpi userSpi;

  public UserResponse getOrCreateUserFromOAuth(
      String email, OAuth2Provider provider, String providerId) {
    return userSpi.getOrCreateUserFromOAuth(email, provider, providerId);
  }
}
