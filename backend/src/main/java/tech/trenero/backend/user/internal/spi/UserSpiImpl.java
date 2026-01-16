package tech.trenero.backend.user.internal.spi;

import java.util.Objects;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import tech.trenero.backend.codegen.types.User;
import tech.trenero.backend.common.enums.OAuth2Provider;
import tech.trenero.backend.user.external.UserSpi;
import tech.trenero.backend.user.internal.service.UserService;

@Component
@RequiredArgsConstructor
public class UserSpiImpl implements UserSpi {
  private final UserService userService;

  @Override
  public User getOrCreateUserFromOAuth2(OAuth2Provider provider, String providerId, String email) {
    Objects.requireNonNull(provider, "provider must not be null");
    Objects.requireNonNull(providerId, "providerId must not be null");

    return userService.getOrCreateUserFromOAuth2(provider, providerId, email);
  }
}
