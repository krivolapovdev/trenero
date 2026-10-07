package org.trenero.backend.common.exception;

import io.jsonwebtoken.JwtException;
import jakarta.persistence.EntityNotFoundException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.ConstraintViolationException;
import java.net.URI;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ProblemDetail;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authorization.AuthorizationDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingRequestCookieException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

  @ExceptionHandler(MethodArgumentNotValidException.class)
  public ProblemDetail handleMethodArgumentNotValidException(
      MethodArgumentNotValidException e, HttpServletRequest request) {
    log.warn("Validation failed for request [{}]: {}", request.getRequestURI(), e.getMessage());

    ProblemDetail problem =
        createProblemDetail(
            HttpStatus.BAD_REQUEST,
            "Validation Failed",
            "One or more fields in the request failed validation",
            request);

    List<Map<String, Object>> errors =
        e.getBindingResult().getFieldErrors().stream()
            .map(
                fieldError ->
                    Map.of(
                        "field",
                        fieldError.getField(),
                        "rejectedValue",
                        fieldError.getRejectedValue() != null
                            ? fieldError.getRejectedValue()
                            : "null",
                        "message",
                        fieldError.getDefaultMessage() != null
                            ? fieldError.getDefaultMessage()
                            : "Validation error"))
            .toList();

    problem.setProperty("errors", errors);
    return problem;
  }

  @ExceptionHandler(ConstraintViolationException.class)
  public ProblemDetail handleConstraintViolationException(
      ConstraintViolationException e, HttpServletRequest request) {
    log.warn("Constraint violation for request [{}]: {}", request.getRequestURI(), e.getMessage());

    ProblemDetail problem =
        createProblemDetail(
            HttpStatus.BAD_REQUEST,
            "Constraint Violation",
            "One or more parameters violated validation constraints",
            request);

    List<Map<String, Object>> errors =
        e.getConstraintViolations().stream()
            .map(
                violation ->
                    Map.of(
                        "property",
                        violation.getPropertyPath().toString(),
                        "invalidValue",
                        violation.getInvalidValue() != null ? violation.getInvalidValue() : "null",
                        "message",
                        violation.getMessage()))
            .toList();

    problem.setProperty("errors", errors);
    return problem;
  }

  @ExceptionHandler(MethodArgumentTypeMismatchException.class)
  public ProblemDetail handleMethodArgumentTypeMismatchException(
      MethodArgumentTypeMismatchException e, HttpServletRequest request) {
    String requiredType =
        e.getRequiredType() != null ? e.getRequiredType().getSimpleName() : "unknown";
    String detail =
        String.format(
            "Parameter '%s' with value '%s' could not be converted to required type '%s'",
            e.getName(), e.getValue(), requiredType);
    log.warn("Type mismatch for request [{}]: {}", request.getRequestURI(), detail);

    return createProblemDetail(HttpStatus.BAD_REQUEST, "Invalid Parameter Type", detail, request);
  }

  @ExceptionHandler(HttpMessageNotReadableException.class)
  public ProblemDetail handleHttpMessageNotReadableException(
      HttpMessageNotReadableException e, HttpServletRequest request) {
    log.warn(
        "Malformed request body for request [{}]: {}", request.getRequestURI(), e.getMessage());
    return createProblemDetail(
        HttpStatus.BAD_REQUEST,
        "Malformed Request Body",
        "Request body is missing or has invalid format",
        request);
  }

  @ExceptionHandler({
    IllegalArgumentException.class,
    MissingRequestCookieException.class,
    MissingServletRequestParameterException.class
  })
  public ProblemDetail handleBadRequestExceptions(Exception e, HttpServletRequest request) {
    log.warn("Bad request for [{}]: {}", request.getRequestURI(), e.getMessage());
    return createProblemDetail(HttpStatus.BAD_REQUEST, "Bad Request", e.getMessage(), request);
  }

  @ExceptionHandler({
    JwtException.class,
    BadCredentialsException.class,
    AuthenticationException.class
  })
  public ProblemDetail handleUnauthorizedExceptions(Exception e, HttpServletRequest request) {
    log.warn("Unauthorized request [{}]: {}", request.getRequestURI(), e.getMessage());
    return createProblemDetail(
        HttpStatus.UNAUTHORIZED,
        "Unauthorized",
        "Authentication failed or token is invalid",
        request);
  }

  @ExceptionHandler({AuthorizationDeniedException.class, AccessDeniedException.class})
  public ProblemDetail handleForbiddenExceptions(Exception e, HttpServletRequest request) {
    log.warn("Forbidden access attempt to [{}]: {}", request.getRequestURI(), e.getMessage());
    return createProblemDetail(
        HttpStatus.FORBIDDEN,
        "Forbidden",
        "You do not have permission to access this resource",
        request);
  }

  @ExceptionHandler({EntityNotFoundException.class, NoResourceFoundException.class})
  public ProblemDetail handleNotFoundExceptions(Exception e, HttpServletRequest request) {
    log.warn("Resource not found for [{}]: {}", request.getRequestURI(), e.getMessage());
    return createProblemDetail(HttpStatus.NOT_FOUND, "Not Found", e.getMessage(), request);
  }

  @ExceptionHandler(DataIntegrityViolationException.class)
  public ProblemDetail handleDataIntegrityViolationException(
      DataIntegrityViolationException e, HttpServletRequest request) {
    log.warn(
        "Data integrity violation for request [{}]: {}", request.getRequestURI(), e.getMessage());
    return createProblemDetail(
        HttpStatus.CONFLICT,
        "Conflict",
        "A database integrity constraint violation occurred",
        request);
  }

  @ExceptionHandler(ResponseStatusException.class)
  public ProblemDetail handleResponseStatusException(
      ResponseStatusException e, HttpServletRequest request) {
    log.warn(
        "ResponseStatusException occurred for [{}]: status={}, reason={}",
        request.getRequestURI(),
        e.getStatusCode(),
        e.getReason());

    HttpStatus resolvedStatus = HttpStatus.resolve(e.getStatusCode().value());
    String title = resolvedStatus != null ? resolvedStatus.getReasonPhrase() : "HTTP Error";

    return createProblemDetail(
        e.getStatusCode(), title, e.getReason() != null ? e.getReason() : e.getMessage(), request);
  }

  @ExceptionHandler(Exception.class)
  public ProblemDetail handleUnhandledException(Exception e, HttpServletRequest request) {
    log.error(
        "Unhandled internal server error occurred for request [{}]", request.getRequestURI(), e);
    return createProblemDetail(
        HttpStatus.INTERNAL_SERVER_ERROR,
        "Internal Server Error",
        "An unexpected error occurred. Please contact support or try again later.",
        request);
  }

  private ProblemDetail createProblemDetail(
      HttpStatusCode status, String title, String detail, HttpServletRequest request) {
    ProblemDetail problem = ProblemDetail.forStatusAndDetail(status, detail);
    problem.setTitle(title);
    if (request != null && request.getRequestURI() != null) {
      problem.setInstance(URI.create(request.getRequestURI()));
    }
    problem.setProperty("timestamp", Instant.now().toString());
    return problem;
  }
}
