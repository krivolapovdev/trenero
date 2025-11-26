package tech.trenero.backend.group.request;

import jakarta.validation.constraints.NotBlank;

public record GroupRequest(@NotBlank String name) {
}
