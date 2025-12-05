// src/main/java/io/github/jahee24/justaday/dto/GeminiRequest.java
package io.github.jahee24.justaday.dto;

import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
@Builder
public class GeminiRequest {
    private List<Content> contents;

    public static GeminiRequest create(String prompt) {
        // 단일 프롬프트로 요청 객체를 생성합니다.
        return GeminiRequest.builder()
                .contents(List.of(
                        Content.builder()
                                .role("user")
                                .parts(List.of(
                                        Part.builder().text(prompt).build()
                                ))
                                .build()
                ))
                .build();
    }

    @Data
    @Builder
    public static class Content {
        private String role;
        private List<Part> parts;
    }

    @Data
    @Builder
    public static class Part {
        private String text;
    }
}