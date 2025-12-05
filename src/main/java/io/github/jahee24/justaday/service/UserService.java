// src/main/java/io/github/jahee24/justaday/service/UserService.java (인터페이스 새로 생성)
package io.github.jahee24.justaday.service;

import io.github.jahee24.justaday.dto.PersonaUpdateRequest;
import io.github.jahee24.justaday.dto.UserResponse;
import io.github.jahee24.justaday.entity.User;

public interface UserService {
    UserResponse getUserInfo(String userId);
    void updatePersona(String userId, PersonaUpdateRequest request);
    void updateUserName(String userId, String name);
}