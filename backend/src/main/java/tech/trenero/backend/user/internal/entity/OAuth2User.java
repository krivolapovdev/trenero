package tech.trenero.backend.user.internal.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import tech.trenero.backend.common.enums.OAuth2Provider;

@Entity
@Table(name = "users", schema = "users_module")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class OAuth2User {
  @Id
  @Column(name = "id")
  private UUID id = UUID.randomUUID();

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
