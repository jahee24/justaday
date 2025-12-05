// src/main/java/io/github/jahee24/justaday/dto/UserResponse.java
package io.github.jahee24.justaday.dto;

import io.github.jahee24.justaday.entity.User;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UserResponse {
    private String userId;
    private String name;
    private int aiPersonaId;

    public static UserResponse fromEntity(User user) {
        return UserResponse.builder()
                .userId(user.getUserId())
                .name(user.getName())
                .aiPersonaId(user.getAiPersonaId())
                .build();
    }
}