package tech.trenero.backend.user.internal.entity;

import com.github.f4b6a3.uuid.UuidCreator;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import tech.trenero.backend.common.enums.OAuth2Provider;

@Entity
@Table(
    name = "users",
    schema = "users_module",
    uniqueConstraints = {
      @UniqueConstraint(
          name = "uq_users_provider_id",
          columnNames = {"provider", "provider_id"})
    })
@Data
@NoArgsConstructor
@AllArgsConstructor
public class OAuth2User {
  @Id
  @Column(name = "id", updatable = false, nullable = false)
  private UUID id = UuidCreator.getTimeOrderedEpoch();

  @Column(name = "email", nullable = false)
  private String email;

  @Enumerated(EnumType.STRING)
  @Column(name = "provider", nullable = false)
  private OAuth2Provider provider;

  @Column(name = "provider_id", nullable = false)
  private String providerId;

  public OAuth2User(String email, OAuth2Provider provider, String providerId) {
    this.email = email;
    this.provider = provider;
    this.providerId = providerId;
  }
}
