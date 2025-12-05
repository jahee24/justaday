// src/main/java/io/github/jahee24/justaday/service/GeminiClientService.java
package io.github.jahee24.justaday.service;

import io.github.jahee24.justaday.dto.GeminiResponse;
import io.github.jahee24.justaday.dto.GeminiRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
public class GeminiClientServiceImpl implements GeminiClientService {

    private final WebClient geminiWebClient; // WebClientConfig에서 정의한 Bean 주입

    // Gemini API 호출 및 응답 받는 핵심 메서드
    public Mono<GeminiResponse> generateContent(String prompt) {
        // Gemini API 호출을 위한 Request Body 구성
        GeminiRequest request = GeminiRequest.create(prompt);

        return geminiWebClient.post()
                .uri("/models/gemini-2.5-flash:generateContent") // 호출 엔드포인트
                .bodyValue(request)
                .retrieve()
                // 상태 코드가 4xx, 5xx일 경우 오류 처리
                .onStatus(status -> status.is4xxClientError() || status.is5xxServerError(),
                        clientResponse -> Mono.error(new RuntimeException("Gemini API Error: " + clientResponse.statusCode())))
                .bodyToMono(GeminiResponse.class); // 응답을 GeminiResponse DTO로 변환
    }
}