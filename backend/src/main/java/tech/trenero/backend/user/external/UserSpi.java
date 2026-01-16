package tech.trenero.backend.user.external;

import tech.trenero.backend.codegen.types.User;
import tech.trenero.backend.common.enums.OAuth2Provider;

public interface UserSpi {
  User getOrCreateUserFromOAuth2(OAuth2Provider provider, String providerId, String email);
}
