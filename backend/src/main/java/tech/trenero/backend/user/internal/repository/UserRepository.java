package tech.trenero.backend.user.internal.repository;

import java.util.Optional;
import java.util.UUID;
import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import tech.trenero.backend.common.model.OAuth2Provider;
import tech.trenero.backend.user.internal.entity.OAuth2User;

@Repository
public interface UserRepository extends JpaRepository<@NonNull OAuth2User, @NonNull UUID> {
  @Query(
      """
          SELECT u
          FROM OAuth2User AS u
          WHERE u.provider = :provider
            AND u.providerId = :providerId
            AND u.deletedAt IS NULL""")
  Optional<OAuth2User> findByProviderAndProviderId(
      @Param("provider") OAuth2Provider provider, @Param("providerId") String providerId);
}
