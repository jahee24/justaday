// src/main/java/io/github/jahee24/justaday/dto/GeminiResponse.java
package io.github.jahee24.justaday.dto;

import lombok.Data;
import lombok.extern.slf4j.Slf4j;

import java.util.List;

@Slf4j
@Data
public class GeminiResponse {
    private List<Candidate> candidates;

    // AI가 생성한 텍스트를 추출하는 헬퍼 메서드
    public String getGeneratedText() {
        try {
            if (candidates != null && !candidates.isEmpty()) {
                Candidate candidate = candidates.get(0);
                if (candidate.content != null && candidate.content.parts != null && !candidate.content.parts.isEmpty()) {
                    return candidate.content.parts.get(0).text;
                }
            }
        } catch (Exception e) {
            log.error(e.getMessage(), e);
        }
        return "";

    }

    @Data
    public static class Candidate {
        private Content content;
    }

    @Data
    public static class Content {
        private List<Part> parts;
    }

    @Data
    public static class Part {
        private String text;
    }
}