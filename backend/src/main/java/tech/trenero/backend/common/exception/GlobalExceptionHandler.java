package tech.trenero.backend.common.exception;

import graphql.GraphQLError;
import graphql.GraphqlErrorBuilder;
import io.jsonwebtoken.JwtException;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.ConstraintViolationException;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.graphql.data.method.annotation.GraphQlExceptionHandler;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authorization.AuthorizationDeniedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;

@ControllerAdvice
@Slf4j
public class GlobalExceptionHandler {
  public static final String BAD_REQUEST = "BAD_REQUEST";
  public static final String UNAUTHENTICATED = "UNAUTHENTICATED";

  @GraphQlExceptionHandler
  public GraphQLError handleConstraintViolation(ConstraintViolationException ex) {
    return buildError(ex, Map.of("code", BAD_REQUEST));
  }

  @GraphQlExceptionHandler
  public GraphQLError handleMethodArgumentNotValid(MethodArgumentNotValidException ex) {
    return buildError(ex, Map.of("code", BAD_REQUEST));
  }

  @GraphQlExceptionHandler
  public GraphQLError handleJwtException(JwtException ex) {
    return buildError(ex, Map.of("code", UNAUTHENTICATED));
  }

  @GraphQlExceptionHandler
  public GraphQLError handleAuthorizationDenied(AuthorizationDeniedException ex) {
    return buildError(ex, Map.of("code", UNAUTHENTICATED));
  }

  @GraphQlExceptionHandler
  public GraphQLError handleAccessDenied(AccessDeniedException ex) {
    return buildError(ex, Map.of("code", UNAUTHENTICATED));
  }

  @GraphQlExceptionHandler
  public GraphQLError handleEntityNotFound(EntityNotFoundException ex) {
    return buildError(ex, Map.of("code", "NOT_FOUND"));
  }

  @GraphQlExceptionHandler
  public GraphQLError handleDataIntegrityViolation(DataIntegrityViolationException ex) {
    return buildError(ex, Map.of("code", "CONFLICT"));
  }

  @GraphQlExceptionHandler
  public GraphQLError handleIllegalArgument(IllegalArgumentException ex) {
    return buildError(ex, Map.of("code", BAD_REQUEST));
  }

  @GraphQlExceptionHandler
  public GraphQLError handleUnexpectedException(Exception ex) {
    log.error("Unexpected GraphQL error", ex);
    return buildError(ex, Map.of("code", "INTERNAL_SERVER_ERROR"));
  }

  private GraphQLError buildError(Throwable cause, Map<String, Object> extensions) {
    log.warn("{} Occurred: {}", cause.getClass().getSimpleName(), cause.getMessage());

    return GraphqlErrorBuilder.newError()
        .message(cause.getMessage())
        .extensions(extensions)
        .build();
  }
}
