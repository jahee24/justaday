//src/main/java/io/github/jahee24/justaday/service/CustomUserDetailsServiceImpl.java
package io.github.jahee24.justaday.service;

import io.github.jahee24.justaday.security.CustomUserDetails;
import io.github.jahee24.justaday.entity.User;
import io.github.jahee24.justaday.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class CustomUserDetailsServiceImpl implements CustomUserDetailsService, UserDetailsService {
    private final UserRepository userRepository;

    /**
     * JWT 필터에서 userId를 받아 DB에서 사용자 정보를 로드합니다.
     * UserDetails 객체를 반환하여 Security Context에 저장합니다.
     */
    @Override
    public UserDetails loadUserByUsername(String userId) throws UsernameNotFoundException {
        // 1. DB에서 사용자 조회
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with userId: " + userId));

        log.debug("Loading UserDetails for userId: " + userId);

        // 2. Spring Security가 사용할 UserDetails 객체 생성 및 반환
        // Note: 이 프로젝트는 권한(Roles)이 단순하므로, UserDetails를 구현한 CustomUserDetails 객체를 반환합니다.
        return new CustomUserDetails(user);
    }
}
