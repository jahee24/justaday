// src/main/java/io/github/jahee24/justaday/config/security/CustomUserDetails.java
package io.github.jahee24.justaday.security;


import io.github.jahee24.justaday.entity.User;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

@Getter
@RequiredArgsConstructor
public class CustomUserDetails implements UserDetails {

    private final User user; // 우리의 User Entity

    // Note: 권한은 단순하게 'USER' 권한만 부여합니다.
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_USER"));
    }

    @Override
    public String getPassword() {
        return user.getPasswordHash(); // 해시된 비밀번호 반환
    }

    @Override
    public String getUsername() {
        return user.getUserId(); // 사용자 ID 반환
    }

    // 계정 만료, 잠김, 자격 증명 만료, 활성화 여부는 MVP에서 모두 True로 설정합니다.
    @Override
    public boolean isAccountNonExpired() { return true; }

    @Override
    public boolean isAccountNonLocked() { return true; }

    @Override
    public boolean isCredentialsNonExpired() { return true; }

    @Override
    public boolean isEnabled() { return true; }
}