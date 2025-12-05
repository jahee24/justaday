// src/main/java/io/github/jahee24/justaday/config/ShedLockConfig.java

package io.github.jahee24.justaday.config;

import net.javacrumbs.shedlock.core.LockProvider;
import net.javacrumbs.shedlock.provider.jdbctemplate.JdbcTemplateLockProvider;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;

import javax.sql.DataSource;

@Configuration
public class ShedLockConfig {
    @Bean
    public LockProvider lockProvider(DataSource dataSource) {
        return new JdbcTemplateLockProvider(
                JdbcTemplateLockProvider.Configuration.builder()
                        .withTableName("shedlock") // 위에서 생성한 테이블 이름
                        .withJdbcTemplate(new JdbcTemplate(dataSource)) // ★withJdbcTemplate 사용★                        .withTimeZone(java.time.ZoneId.systemDefault()) // 서버의 타임존 설정
                        .build()
        );
    }
}