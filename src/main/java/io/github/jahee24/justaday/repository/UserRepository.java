//src/main/java/io/github/jahee24/justaday/repository/UserRepository.java
package io.github.jahee24.justaday.repository;

import io.github.jahee24.justaday.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
     Optional<User> findByUserId(String userId);
     User save(User user);
     @Query("SELECT u.id FROM User u")
     List<Long> findAllUserIds();
}
