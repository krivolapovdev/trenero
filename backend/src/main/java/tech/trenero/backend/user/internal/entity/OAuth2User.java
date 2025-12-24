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
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.NonNull;
import tech.trenero.backend.common.enums.OAuth2Provider;

@Entity
@Table(
    name = "users",
    schema = "users_module",
    uniqueConstraints = {@UniqueConstraint(columnNames = {"provider", "provider_id"})})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OAuth2User {
  @Id
  @Column(name = "id", updatable = false, nullable = false)
  @Builder.Default
  private UUID id = UuidCreator.getTimeOrderedEpoch();

  @Enumerated(EnumType.STRING)
  @Column(name = "provider", nullable = false, updatable = false)
  @NonNull
  private OAuth2Provider provider;

  @Column(name = "provider_id", nullable = false, updatable = false)
  @NonNull
  private String providerId;

  @Column(name = "email", nullable = false)
  @NonNull
  private String email;
}
