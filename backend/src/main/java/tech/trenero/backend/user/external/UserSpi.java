package tech.trenero.backend.user.external;

import tech.trenero.backend.common.dto.UserDto;
import tech.trenero.backend.common.enums.OAuth2Provider;

public interface UserSpi {
  UserDto getOrCreateUserFromOAuth2(OAuth2Provider provider, String providerId, String email);
}
