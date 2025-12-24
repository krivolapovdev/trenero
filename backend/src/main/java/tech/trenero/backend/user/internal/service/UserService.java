package tech.trenero.backend.user.internal.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.enums.OAuth2Provider;
import tech.trenero.backend.common.response.UserResponse;
import tech.trenero.backend.user.internal.entity.OAuth2User;
import tech.trenero.backend.user.internal.mapper.UserMapper;
import tech.trenero.backend.user.internal.repository.UserRepository;

@Service
@Slf4j
@RequiredArgsConstructor
public class UserService {
  private final UserRepository userRepository;
  private final UserMapper userMapper;

  @Transactional
  public UserResponse getOrCreateUserFromOAuth2(
      String email, OAuth2Provider provider, String providerId) {
    log.info(
        "Getting or creating user from OAuth2: email={}, provider={}, providerId={}",
        email,
        provider,
        providerId);

    return userRepository
        .findByProviderAndProviderId(provider, providerId)
        .map(userMapper::toUserResponse)
        .orElseGet(() -> createNewUser(email, provider, providerId));
  }

  private UserResponse createNewUser(String email, OAuth2Provider provider, String providerId) {
    log.info("User not found. Creating new user for email: {}", email);

    OAuth2User newUser = new OAuth2User(email, provider, providerId);
    OAuth2User savedUser = saveUser(newUser);

    log.info("New user created: {}", savedUser.getEmail());
    return userMapper.toUserResponse(savedUser);
  }

  private OAuth2User saveUser(OAuth2User user) {
    log.info("Saving user: {}", user);
    return userRepository.save(user);
  }
}
