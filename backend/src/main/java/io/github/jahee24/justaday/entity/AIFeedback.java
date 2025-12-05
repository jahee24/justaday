// src/main/java/io/github/jahee24/justaday/entity/AIFeedback.java
package io.github.jahee24.justaday.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "ai_feedbacks")
@Getter
@Setter
@NoArgsConstructor
public class AIFeedback {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // JournalLog와의 관계 (FK)
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "journal_id", nullable = false)
    private JournalLog journal; // 피드백이 연결된 저널

    @Column(columnDefinition = "TEXT", nullable = false)
    private String mentText; // AI의 주요 멘트 (피드백 본문)

    // Mini Plans를 JSON 문자열로 저장합니다.
    @Column(columnDefinition = "TEXT", nullable = false)
    private String miniPlansJson; // JSON 형식의 미니 계획 목록

    @CreationTimestamp
    private LocalDateTime createdAt;

    public void setJournal(JournalLog journalLog) {
        // 1. AIFeedback 측의 외래 키 설정 (DB 저장에 필요)
        this.journal = journalLog;

        // 2. JournalLog 객체의 참조 일관성 유지 (객체 그래프에 필요)
        if (journalLog.getAiFeedback() != this) {
            journalLog.setAiFeedback(this);
        }
    }
}