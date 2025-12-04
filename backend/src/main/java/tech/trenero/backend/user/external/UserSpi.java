package tech.trenero.backend.user.external;

import tech.trenero.backend.common.enums.OAuth2Provider;
import tech.trenero.backend.common.response.UserResponse;

public interface UserSpi {
  UserResponse getOrCreateUserFromOAuth(String email, OAuth2Provider provider, String providerId);
}
