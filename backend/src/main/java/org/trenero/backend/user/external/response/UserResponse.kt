package org.trenero.backend.user.external.response

import io.swagger.v3.oas.annotations.media.Schema
import java.util.UUID

data class UserResponse(
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val id: UUID,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val email: String,
)
