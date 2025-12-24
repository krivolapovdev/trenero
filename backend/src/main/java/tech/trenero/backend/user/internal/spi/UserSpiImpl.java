package tech.trenero.backend.user.internal.spi;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.dto.UserDto;
import tech.trenero.backend.common.enums.OAuth2Provider;
import tech.trenero.backend.user.external.UserSpi;
import tech.trenero.backend.user.internal.service.UserService;

@Component
@RequiredArgsConstructor
public class UserSpiImpl implements UserSpi {
  private final UserService userService;

  @Override
  public UserDto getOrCreateUserFromOAuth2(
      OAuth2Provider provider, String providerId, String email) {
    return userService.getOrCreateUserFromOAuth2(provider, providerId, email);
  }
}
