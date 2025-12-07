package io.github.jahee24.justaday.service;

import io.github.jahee24.justaday.dto.PersonaUpdateRequest;
import io.github.jahee24.justaday.dto.UserResponse;
import io.github.jahee24.justaday.entity.User;
import io.github.jahee24.justaday.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Transactional
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;

    @Override
    public UserResponse getUserInfo(String userId) {
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + userId));
        return UserResponse.fromEntity(user);
    }

    @Override
    public void updatePersona(String userId, PersonaUpdateRequest request) {
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + userId));
        user.setAiPersonaId(request.getPersonaId());
        userRepository.save(user);
    }

    @Override
    public void updateUserName(String userId, String name) {
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + userId));
        if (user.getName() != null && !user.getName().trim().isEmpty()) {
            throw new RuntimeException("이름은 이미 설정되어 수정할 수 없습니다.");
        }
        user.setName(name);
        userRepository.save(user);
    }

    @Override
    public void deleteUser(String userId) {
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + userId));
        userRepository.delete(user);
    }
}
