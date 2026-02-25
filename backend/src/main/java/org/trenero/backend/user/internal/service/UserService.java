package org.trenero.backend.user.internal.service;

import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFoundSupplier;

import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.trenero.backend.common.domain.OAuth2Provider;
import org.trenero.backend.common.response.UserResponse;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.user.external.UserSpi;
import org.trenero.backend.user.internal.domain.OAuth2User;
import org.trenero.backend.user.internal.mapper.UserMapper;
import org.trenero.backend.user.internal.repository.UserRepository;

@Service
@Slf4j
@RequiredArgsConstructor
public class UserService implements UserSpi {
  private final UserRepository userRepository;
  private final UserMapper userMapper;

  @Transactional
  public @NonNull UserResponse getOrCreateUserFromOAuth2(
      @NonNull OAuth2Provider provider, @NonNull String providerId, @NonNull String email) {
    log.info(
        "Getting or creating user from OAuth2: email={}; provider={}; providerId={}",
        email,
        provider,
        providerId);

    return userRepository
        .findByProviderAndProviderId(provider, providerId)
        .map(userMapper::toResponse)
        .orElseGet(() -> createNewUser(provider, providerId, email));
  }

  private UserResponse createNewUser(
      @NonNull OAuth2Provider provider, @NonNull String providerId, @NonNull String email) {
    log.info("Creating new user: email={}; provider={}", email, provider);

    var newUser =
        OAuth2User.builder()
            .provider(provider)
            .providerId(providerId)
            .email(email.toUpperCase().trim())
            .build();

    var savedUser = saveUser(newUser);

    return userMapper.toResponse(savedUser);
  }

  private OAuth2User saveUser(@NonNull OAuth2User user) {
    log.info("Saving user: user={}", user);
    return userRepository.saveAndFlush(user);
  }

  public void deleteUser(@NonNull JwtUser jwtUser) {
    log.info("Deleting user: user={}", jwtUser);

    OAuth2User oAuth2User =
        userRepository
            .findById(jwtUser.userId())
            .orElseThrow(entityNotFoundSupplier(OAuth2User.class, jwtUser.userId(), jwtUser));

    userRepository.delete(oAuth2User);
  }
}
