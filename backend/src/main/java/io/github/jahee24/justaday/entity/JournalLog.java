// src/main/java/io/github/jahee24/justaday/entity/JournalLog.java
package io.github.jahee24.justaday.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "journal_logs")
@Getter
@Setter
@NoArgsConstructor
public class JournalLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // User와의 관계 (FK)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user; // 작성 사용자

    @Column(columnDefinition = "TEXT", nullable = false)
    private String content; // 저널 내용

    // 하루에 한 번만 기록 가능하도록 LocalDate 필드를 추가합니다.
    @Column(nullable = false)
    private LocalDate journalDate; // 저널 작성 날짜 (yyyy-MM-dd)

    @CreationTimestamp
    private LocalDateTime createdAt; // 레코드 생성 시점

    // AIFeedback과의 양방향 OneToOne 관계 추가
    // mappedBy = "journal" : AIFeedback Entity의 'journal' 필드에 의해 관리됨
    @OneToOne(mappedBy = "journal", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private AIFeedback aiFeedback;
}