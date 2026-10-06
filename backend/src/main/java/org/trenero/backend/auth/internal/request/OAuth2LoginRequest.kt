package org.trenero.backend.auth.internal.request

import jakarta.validation.constraints.NotBlank

data class OAuth2LoginRequest(@field:NotBlank val token: String)
