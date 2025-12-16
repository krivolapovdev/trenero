package tech.trenero.backend.user.internal.repository;

import java.util.Optional;
import java.util.UUID;
import org.jspecify.annotations.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import tech.trenero.backend.common.enums.OAuth2Provider;
import tech.trenero.backend.user.internal.entity.OAuth2User;

@Repository
public interface UserRepository extends JpaRepository<@NonNull OAuth2User, @NonNull UUID> {
  @Query(
      """
          SELECT u
          FROM OAuth2User AS u
          WHERE u.provider = :provider
            AND u.providerId = :providerId""")
  Optional<OAuth2User> findByProviderAndProviderId(OAuth2Provider provider, String providerId);
}
