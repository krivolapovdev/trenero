package org.trenero.backend.auth.internal.request

import jakarta.validation.constraints.NotBlank

data class RefreshTokenRequest(@field:NotBlank val refreshToken: String)
