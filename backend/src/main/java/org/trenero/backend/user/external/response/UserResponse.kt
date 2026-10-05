package org.trenero.backend.user.external.response

import jakarta.validation.constraints.NotNull
import java.util.UUID

data class UserResponse(
  @get:NotNull val id: UUID,
  @get:NotNull val email: String,
)
