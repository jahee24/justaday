//src/main/java/io/github/jahee24/justaday/dto/LoginResponse.java
package io.github.jahee24.justaday.dto;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;


@Getter
@Setter
@RequiredArgsConstructor
public class LoginResponse {
    private final String token;
    private final String userId;
    private final String message = "로그인 성공";
}