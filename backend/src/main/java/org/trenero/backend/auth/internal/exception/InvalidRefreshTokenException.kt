package org.trenero.backend.auth.internal.exception

import org.springframework.security.authentication.BadCredentialsException

class InvalidRefreshTokenException : BadCredentialsException {
  constructor(message: String) : super(message)
}
