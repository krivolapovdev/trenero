package org.trenero.backend.auth.internal.exception

import org.springframework.security.authentication.BadCredentialsException

class InvalidGoogleTokenException : BadCredentialsException {
  constructor(message: String) : super(message)

  constructor(message: String, cause: Throwable) : super(message, cause)
}
