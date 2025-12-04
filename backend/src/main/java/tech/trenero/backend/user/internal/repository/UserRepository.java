package tech.trenero.backend.user.internal.repository;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import tech.trenero.backend.common.enums.OAuth2Provider;
import tech.trenero.backend.user.internal.entity.User;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {
  @Query(
      """
          SELECT u
          FROM User u
          WHERE u.provider = :provider
          AND u.providerId = :providerId""")
  Optional<User> findByProviderAndProviderId(OAuth2Provider provider, String providerId);
}
