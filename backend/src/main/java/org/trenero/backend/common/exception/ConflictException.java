package org.trenero.backend.common.exception;

import lombok.Getter;

// A conflict the client knows by name: `code` is stable and the client maps it to
// its own, translated wording, while the reason is the fallback for callers
// without that map.
//
// It does not extend ResponseStatusException on purpose: Spring Boot answers
// those with its own problem detail (spring.mvc.problemdetails.enabled) and that
// answer drops the code.
@Getter
public class ConflictException extends RuntimeException {

  private final String code;

  public ConflictException(String code, String reason) {
    super(reason);
    this.code = code;
  }
}
