package org.trenero.backend.common.exception;

import jakarta.persistence.EntityNotFoundException;
import java.util.Map;
import java.util.UUID;
import java.util.function.Supplier;
import java.util.stream.Collectors;
import lombok.AccessLevel;
import lombok.NoArgsConstructor;
import lombok.NonNull;
import org.trenero.backend.common.security.JwtUser;

@NoArgsConstructor(access = AccessLevel.PRIVATE)
public class ExceptionUtils {
  public static @NonNull Supplier<EntityNotFoundException> entityNotFoundSupplier(
      @NonNull Class<?> entityClass, @NonNull UUID id, @NonNull JwtUser jwtUser) {
    return () -> entityNotFound(entityClass, id, jwtUser);
  }

  public static @NonNull EntityNotFoundException entityNotFound(
      @NonNull Class<?> entityClass, @NonNull UUID id, @NonNull JwtUser jwtUser) {
    return new EntityNotFoundException(
        String.format("%s not found: id={%s} user={%s}", entityClass.getSimpleName(), id, jwtUser));
  }

  public static @NonNull EntityNotFoundException entityNotFound(
      @NonNull Class<?> entityClass,
      @NonNull Map<String, Object> criteria,
      @NonNull JwtUser jwtUser) {
    String criteriaString =
        criteria.entrySet().stream()
            .map(e -> String.format("%s={%s}", e.getKey(), e.getValue()))
            .collect(Collectors.joining(" "));

    return new EntityNotFoundException(
        String.format(
            "%s not found: %s; user={%s}",
            entityClass.getSimpleName(), criteriaString, jwtUser.userId()));
  }
}
