package org.trenero.backend.common.exception;

import io.jsonwebtoken.JwtException;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.ConstraintViolationException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authorization.AuthorizationDeniedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingRequestCookieException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {
  @ExceptionHandler({
    IllegalArgumentException.class,
    MethodArgumentNotValidException.class,
    ConstraintViolationException.class,
    MissingRequestCookieException.class
  })
  public ResponseStatusException handleBadRequestExceptions(Exception e) {
    return buildResponseStatusException(HttpStatus.BAD_REQUEST, e.getMessage(), e);
  }

  @ExceptionHandler(JwtException.class)
  public ResponseStatusException handleUnauthorizedException(JwtException e) {
    return buildResponseStatusException(HttpStatus.UNAUTHORIZED, e.getMessage(), e);
  }

  @ExceptionHandler({AuthorizationDeniedException.class, AccessDeniedException.class})
  public ResponseStatusException handleForbiddenException(AuthorizationDeniedException e) {
    return buildResponseStatusException(HttpStatus.FORBIDDEN, e.getMessage(), e);
  }

  @ExceptionHandler({EntityNotFoundException.class, NoResourceFoundException.class})
  public ResponseStatusException handleNotFoundException(RuntimeException e) {
    return buildResponseStatusException(HttpStatus.NOT_FOUND, e.getMessage(), e);
  }

  @ExceptionHandler(DataIntegrityViolationException.class)
  public ResponseStatusException handleConflictException(DataIntegrityViolationException e) {
    return buildResponseStatusException(HttpStatus.CONFLICT, e.getMessage(), e);
  }

  @ExceptionHandler(Exception.class)
  public ResponseStatusException handleInternalServerError(Exception e) {
    log.error("Unexpected error occurred", e);
    return new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, e.getMessage(), e);
  }

  private ResponseStatusException buildResponseStatusException(
      HttpStatusCode httpStatusCode, String message, Throwable cause) {
    log.warn("{} Occurred: {}", cause.getClass().getSimpleName(), message);
    return new ResponseStatusException(httpStatusCode, message, cause);
  }
}
