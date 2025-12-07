package io.github.jahee24.justaday.service;

import io.github.jahee24.justaday.dto.PersonaUpdateRequest;
import io.github.jahee24.justaday.dto.UserResponse;

public interface UserService {
    UserResponse getUserInfo(String userId);
    void updatePersona(String userId, PersonaUpdateRequest request);
    void updateUserName(String userId, String name);
    void deleteUser(String userId);
}
