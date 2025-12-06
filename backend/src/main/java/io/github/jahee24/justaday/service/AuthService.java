//src/main/java/io/github/jahee24/justaday/service/AuthService.java
package io.github.jahee24.justaday.service;

import io.github.jahee24.justaday.dto.LoginRequest;
import io.github.jahee24.justaday.dto.LoginResponse;
import io.github.jahee24.justaday.dto.SignupRequest;

public interface AuthService {
    void signup(SignupRequest request);
    LoginResponse login(LoginRequest request);
    boolean isUserIdExists(String userId);
}
