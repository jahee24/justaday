// src/main/java/io/github/jahee24/justaday/config/WebClientConfig.java
package io.github.jahee24.justaday.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class WebClientConfig {

    //  Railway Variables 탭에서 설정할 환경 변수
    @Value("${GEMINI_API_KEY}")
    private String geminiApiKey;

    //  WebClient Bean 정의
    @Bean
    public WebClient geminiWebClient(WebClient.Builder builder) {
        return builder
                .baseUrl("https://generativelanguage.googleapis.com/v1beta")
                .defaultHeader("Content-Type", "application/json")
                // 모든 요청에 API Key를 헤더로 추가
                .defaultHeader("x-goog-api-key", geminiApiKey)
                .build();
    }
}