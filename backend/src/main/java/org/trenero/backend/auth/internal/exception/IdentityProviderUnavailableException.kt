package org.trenero.backend.auth.internal.exception

class IdentityProviderUnavailableException(message: String, cause: Throwable? = null) :
  IllegalStateException(message, cause)
