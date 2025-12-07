package io.github.jahee24.justaday.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false, length = 50)
    private String userId;

    @Column(nullable = true, length = 50)
    private String name;

    @Column(name = "password_hash", nullable = false, length = 100)
    private String passwordHash;

    @Column(nullable = false)
    private int aiPersonaId;

    @Column(columnDefinition = "integer default 0")
    private int totalFeedbackCount;

    @Column(columnDefinition = "TEXT")
    private String habitHistorySummary;

    @Column(nullable = true)
    private LocalDate lastSummaryUpdatedDate;

    @CreationTimestamp
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<JournalLog> journalLogs = new ArrayList<>();
}
