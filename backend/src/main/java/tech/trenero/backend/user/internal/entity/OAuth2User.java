package tech.trenero.backend.user.internal.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.NonNull;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import tech.trenero.backend.common.enums.OAuth2Provider;

@Entity
@Table(name = "oauth2_users", schema = "users_module")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OAuth2User {
  @Id
  @Column(name = "id", updatable = false, nullable = false)
  @GeneratedValue(strategy = GenerationType.UUID)
  private UUID id;

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

  @CreationTimestamp
  @Column(name = "created_at", nullable = false, updatable = false)
  private OffsetDateTime createdAt;

  @UpdateTimestamp
  @Column(name = "updated_at", nullable = false)
  private OffsetDateTime updatedAt;

  @Column(name = "deleted_at")
  private OffsetDateTime deletedAt;
}
