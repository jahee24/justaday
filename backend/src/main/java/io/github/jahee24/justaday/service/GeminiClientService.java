package io.github.jahee24.justaday.service;

import io.github.jahee24.justaday.dto.GeminiResponse;
import reactor.core.publisher.Mono;

public interface GeminiClientService {
    Mono<GeminiResponse> generateContent(String prompt);
}
