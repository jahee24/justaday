//src/main/java/io/github/jahee24/justaday/service/AuthService.java
package io.github.jahee24.justaday.service;

import io.github.jahee24.justaday.dto.LoginRequest;
import io.github.jahee24.justaday.dto.LoginResponse;
import io.github.jahee24.justaday.dto.SignupRequest;
import io.github.jahee24.justaday.entity.User;

public interface AuthService {
    User signup(SignupRequest request);

    LoginResponse login(LoginRequest request);
}
