//src/main/java/io/github/jahee24/justaday/dto/LoginRequest.java
package io.github.jahee24.justaday.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.*;


@Getter
@Setter
@NoArgsConstructor
public class LoginRequest {
    @NotBlank
    private String userId;

    @NotBlank
    private String password;
}
}
