package org.trenero.backend.auth.internal.exception

import org.springframework.security.authentication.BadCredentialsException

class InvalidReviewerKeyException : BadCredentialsException("Invalid reviewer key")
