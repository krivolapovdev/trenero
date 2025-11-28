package tech.trenero.backend.common.exception;

import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.ConstraintViolationException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {
  @ExceptionHandler(EntityNotFoundException.class)
  public ResponseStatusException handleException(EntityNotFoundException e) {
    return buildResponseStatusException(HttpStatus.NOT_FOUND, e.getMessage(), e);
  }

  @ExceptionHandler(IllegalArgumentException.class)
  public ResponseStatusException handleIllegalArgument(IllegalArgumentException e) {
    return buildResponseStatusException(HttpStatus.BAD_REQUEST, e.getMessage(), e);
  }

  @ExceptionHandler({MethodArgumentNotValidException.class, ConstraintViolationException.class})
  public ResponseStatusException handleValidationException(Exception e) {
    return buildResponseStatusException(HttpStatus.BAD_REQUEST, e.getMessage(), e);
  }

  @ExceptionHandler(DataIntegrityViolationException.class)
  public ResponseStatusException handleDataIntegrityViolation(DataIntegrityViolationException e) {
    return buildResponseStatusException(HttpStatus.CONFLICT, e.getMessage(), e);
  }

  @ExceptionHandler(Exception.class)
  public ResponseStatusException handleException(Exception e) {
    log.error("Unexpected error occurred", e);
    return new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, e.getMessage(), e);
  }

  private ResponseStatusException buildResponseStatusException(
      HttpStatusCode httpStatusCode, String message, Throwable cause) {
    log.warn("{} Occurred: {}", cause.getClass().getSimpleName(), message);
    return new ResponseStatusException(httpStatusCode, message, cause);
  }
}
