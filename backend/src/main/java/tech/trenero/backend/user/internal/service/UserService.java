package tech.trenero.backend.user.internal.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.dto.UserDto;
import tech.trenero.backend.common.enums.OAuth2Provider;
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
  public UserDto getOrCreateUserFromOAuth2(
      OAuth2Provider provider, String providerId, String email) {
    log.info(
        "Getting or creating user from OAuth2: email={}, provider={}, providerId={}",
        email,
        provider,
        providerId);

    return userRepository
        .findByProviderAndProviderId(provider, providerId)
        .map(userMapper::toUserResponse)
        .orElseGet(() -> createNewUser(provider, providerId, email));
  }

  private UserDto createNewUser(OAuth2Provider provider, String providerId, String email) {
    log.info("User not found. Creating new user for email: {}", email);

    OAuth2User newUser =
        OAuth2User.builder().provider(provider).providerId(providerId).email(email).build();
    OAuth2User savedUser = saveUser(newUser);

    return userMapper.toUserResponse(savedUser);
  }

  private OAuth2User saveUser(OAuth2User user) {
    log.info("Saving user: {}", user);
    return userRepository.save(user);
  }
}
