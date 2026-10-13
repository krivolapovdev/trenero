package org.trenero.backend.common.exception;

import lombok.AccessLevel;
import lombok.NoArgsConstructor;

/**
 * The codes a problem detail carries on top of its status: the reason of a failure that one status
 * covers several of at once, so that a client can word it itself instead of showing the message of
 * the server. A failure the status already names - a missing session, a record that is gone - needs
 * no code.
 */
@NoArgsConstructor(access = AccessLevel.PRIVATE)
public class ApiErrorCode {

  public static final String STUDENT_NAME_NOT_UNIQUE = "STUDENT_NAME_NOT_UNIQUE";
  public static final String GROUP_NAME_NOT_UNIQUE = "GROUP_NAME_NOT_UNIQUE";
}
