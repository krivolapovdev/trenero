package org.trenero.backend.user.external;

import org.trenero.backend.common.domain.OAuth2Provider;
import org.trenero.backend.common.response.UserResponse;

public interface UserSpi {
  UserResponse getOrCreateUserFromOAuth2(OAuth2Provider provider, String providerId, String email);
}
