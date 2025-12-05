// src/main/java/io/github/jahee24/justaday/dto/PersonaUpdateRequest.java
package io.github.jahee24.justaday.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class PersonaUpdateRequest {
    @NotNull(message = "페르소나 ID는 필수입니다.")
    @Min(value = 1, message = "페르소나 ID는 1 이상이어야 합니다.")
    @Max(value = 3, message = "페르소나 ID는 3 이하여야 합니다.")
    private Integer personaId;
}