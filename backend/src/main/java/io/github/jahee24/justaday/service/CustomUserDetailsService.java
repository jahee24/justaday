//src/main/java/io/github/jahee24/justaday/service/CustomUserDetailsService.java
package io.github.jahee24.justaday.service;

import org.springframework.security.core.userdetails.UserDetails;

public interface CustomUserDetailsService {
    UserDetails loadUserByUsername(String userId);
}
