package io.github.jahee24.justaday;

import net.javacrumbs.shedlock.spring.annotation.EnableSchedulerLock;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
@EnableSchedulerLock(defaultLockAtMostFor = "PT5M") // ShedLock 활성화 및 기본 락 유지 시간 설정 (최대 5분)
public class JustadayApplication {

    public static void main(String[] args) {
        SpringApplication.run(JustadayApplication.class, args);
    }

}
