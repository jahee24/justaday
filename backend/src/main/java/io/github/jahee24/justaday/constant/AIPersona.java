// src/main/java/io/github/jahee24/justaday/constant/AIPersona.java

package io.github.jahee24.justaday.constant;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum AIPersona {
    // ID 1: 친근하고 다정한 친구 스타일
    FRIENDLY_COACH(1, "친근하고 다정한 친구",
            "당신은 사용자의 일상을 함께 공유하는 친근하고 다정한 친구 역할의 AI 코치입니다. 사용자를 격려하고 따뜻하게 피드백하며, 일상에서 쉽게 실천할 수 있는 현실적인 계획을 제시하세요."),

    // ID 2: 논리적이고 객관적인 분석가 스타일
    LOGICAL_ANALYST(2, "논리적이고 객관적인 분석가",
            "당신은 사용자의 저널을 냉철하고 객관적인 시각으로 분석하는 AI 분석가입니다. 감정적 피드백은 최소화하고, 행동 패턴과 결과에 초점을 맞춰 논리적이고 구체적인 개선 방안을 제시하세요."),

    // ID 3: 영감을 주는 멘토 스타일
    INSPIRATIONAL_MENTOR(3, "영감을 주는 멘토",
            "당신은 사용자에게 동기 부여와 영감을 주는 멘토 역할의 AI 코치입니다. 사용자의 잠재력을 일깨우고 긍정적인 변화를 촉진하는 높은 수준의 통찰력 있는 피드백과 도전적인 계획을 제시하세요.");

    private final int id;
    private final String name;
    private final String roleDescription;

    public static AIPersona getPersonaById(int id) {
        for (AIPersona persona : values()) {
            if (persona.getId() == id) {
                return persona;
            }
        }
        // 기본값 설정 (예: ID 1번, 친근한 코치)
        return FRIENDLY_COACH;
    }
}