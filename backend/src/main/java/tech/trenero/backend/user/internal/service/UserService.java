package tech.trenero.backend.user.internal.service;

import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
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

  public UserResponse getUserById(UUID id) {
    log.info("Getting user by id: {}", id);
    return userRepository
        .findById(id)
        .map(userMapper::toUserResponse)
        .orElseThrow(() -> new UsernameNotFoundException("User not found by id: " + id));
  }

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
        .orElseGet(
            () -> {
              log.info("User does not exist. Creating new user for email: {}", email);
              OAuth2User user = new OAuth2User(email, provider, providerId);
              OAuth2User saveUser = saveUser(user);
              return userMapper.toUserResponse(saveUser);
            });
  }

  public OAuth2User saveUser(OAuth2User user) {
    log.info("Saving user: {}", user);
    return userRepository.save(user);
  }
}
