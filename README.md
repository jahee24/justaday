
# ![40.png](images/40.png) Justaday (저스트어데이) 

> **"당신의 하루는 어떤가요? AI가 당신의 감정을 듣고, 위로와 솔루션을 건넵니다."**

[![One Store](images/one_downloadbadge_red_white_kr.png)](https://m.onestore.co.kr/v2/ko-kr/app/0001003418)

**Just a Day**는 사용자의 하루를 기록하고, 3가지 성격의 AI 페르소나가 맞춤형 피드백과 행동 지침(Mini Plans)을 제공하는 **AI 감정 케어 저널 서비스**입니다.

단순한 기록을 넘어, AI와의 상호작용을 통해 사용자가 자신의 감정을 객관적으로 바라보고 긍정적인 습관을 형성하도록 돕습니다.

---

## 📱 Screenshots

|                                               로그인 & 회원가입                                                |                                            페르소나 선택                                            | 일기 작성 | AI 피드백 |
|:-------------------------------------------------------------------------------------------------------:|:---------------------------------------------------------------------------------------------:| :---: | :---: |
| <img src="images/%ED%9A%8C%EC%9B%90%EA%B0%80%EC%9E%85.png" width="200" alt="Login Screen"/> | <img src="images/%EB%AF%B8%EB%A5%B4%EC%84%A4%EC%A0%95.png" width="200" alt="Persona Select"/> | <img src="images/%EC%A0%80%EB%84%90%EC%9E%85%EB%A0%A5.png" width="200" alt="Journal Entry"/> | <img src="images/%EC%98%A4%EB%8A%98%EC%9D%98%ED%94%BC%EB%93%9C%EB%B0%B1.png" width="200" alt="AI Feedback"/> |

---

## 💡 Motivation

매일 일기를 쓰는 것은 정신 건강에 좋지만, 혼자만의 독백으로 끝나기 쉽습니다.
**"내가 쓴 일기에 누군가 다정하게, 때로는 이성적으로 답해준다면 어떨까?"** 라는 생각에서 출발했습니다.
LLM(Large Language Model)을 활용해 사용자의 감정을 분석하고, 즉각적인 피드백을 제공함으로써 **'기록하는 즐거움'**과 **'심리적 케어'**를 동시에 제공하고자 했습니다.

---

## ✨ Key Features

### 1. 📝 하루 기록 (Daily Journal)
- **직관적인 입력**: 슬라이더(Slider)를 이용한 상태 레벨 입력과 자동 줄바꿈 텍스트 필드로 사용자 경험을 최적화했습니다.
- **1일 1로그**: 하루에 하나의 기록만 남길 수 있어 꾸준한 습관 형성을 돕습니다.

### 2. 🤖 AI 페르소나 피드백
사용자의 성향에 맞는 3가지 AI 페르소나 중 하나를 선택할 수 있습니다.
- **미르 (MIR) 🍊**: 따뜻한 공감과 위로를 전하는 친구 (감성 중심)
- **해리 (HARRY) 🔵**: 데이터와 논리로 효율적인 해결책을 제시하는 분석가 (이성 중심)
- **오든 (ODEN) 🟢**: 고전의 지혜와 평온함을 전하는 멘토 (철학 중심)

### 3. ⚡️ 실시간 AI 코칭 (Real-time Coaching)
- **비동기 처리**: 백엔드에서 별도 스레드로 AI 파이프라인이 실행되어 사용자 대기 시간을 최소화했습니다.
- **실시간 확인**: 프론트엔드 폴링(Polling)을 통해 피드백 생성 즉시 화면에 표시됩니다.

### 4. 🧠 장기 기억 및 패턴 분석 (Long-term Memory)
- **주간 요약**: 매일 새벽 스케줄러가 사용자의 최근 7일 기록을 분석하여 AI에게 '장기 기억'을 주입합니다.
- **맥락 유지**: 단순한 일회성 피드백을 넘어, 사용자의 과거 기록을 바탕으로 변화된 감정 패턴을 인식하고 조언합니다.

---

## 🧠 AI Prompt Engineering

단순한 API 호출을 넘어, 페르소나의 일관성을 유지하기 위해 정교한 프롬프트를 설계했습니다.

- **Role-Playing**: 각 페르소나(미르, 해리, 오든)의 말투, 어조, 강조하는 가치를 시스템 프롬프트에 명시했습니다.
- **Context Injection**: 사용자의 **최근 3일간의 기록(단기 기억)**과 **주간 요약(장기 기억)**을 프롬프트에 동적으로 주입하여, AI가 사용자의 맥락을 이해하고 답변하도록 구현했습니다.
- **Structured Output**: JSON 형식을 강제하여 프론트엔드에서 파싱하기 쉬운 구조화된 데이터(멘트, 미니 플랜)를 받습니다.

---

## 🔥 Technical Challenges & Solutions

### 1. AI 응답 지연으로 인한 UX 저하 해결
- **문제**: Gemini API 호출 및 응답 생성에 평균 3~5초가 소요되어, 사용자가 '제출' 버튼을 누른 후 하염없이 기다려야 하는 문제가 발생했습니다.
- **해결**: **비동기(Async) 처리와 폴링(Polling) 기법**을 도입했습니다.
    1. 클라이언트가 저널을 제출하면 서버는 즉시 `201 Created`를 응답하여 UI 멈춤을 방지합니다.
    2. 서버는 `@Async` 어노테이션을 활용해 별도 스레드에서 AI API를 호출합니다.
    3. 클라이언트는 3초 간격으로 서버에 피드백 생성 여부를 묻는 폴링 요청을 보냅니다.
    4. 피드백이 생성되면 즉시 화면에 렌더링합니다.
- **성과**: 사용자 체감 대기 시간을 0초로 단축하고, 앱의 반응성을 크게 향상시켰습니다.

### 2. 안드로이드 보안 정책 및 네트워크 이슈 대응
- **문제**: 로컬 개발 환경에서는 잘 동작하던 앱이 릴리즈 빌드 후 로그인/회원가입이 되지 않는 문제가 발생했습니다.
- **원인**: Android 9 이상부터 적용되는 **Cleartext Traffic(HTTP) 차단 정책**과 릴리즈 모드에서의 엄격한 네트워크 보안 설정 때문이었습니다.
- **해결**:
    - `AndroidManifest.xml`에 `android:usesCleartextTraffic="true"` 설정을 추가하여 HTTP 통신을 허용했습니다.
    - `Dio` 클라이언트의 `connectTimeout`, `receiveTimeout`을 늘려 불안정한 네트워크 환경에서도 요청이 실패하지 않도록 안정성을 확보했습니다.
- **배운 점**: 개발 환경(Debug)과 배포 환경(Release)의 차이를 이해하고, OS별 보안 정책을 미리 검토하는 것의 중요성을 배웠습니다.

### 3. Flutter 위젯 생명주기(Lifecycle) 오류 해결
- **문제**: 로그아웃 시 `setState() called after dispose()` 오류가 발생하며 앱이 비정상 종료되는 현상이 있었습니다. 비동기 작업 후 화면이 이미 사라진 상태에서 UI를 업데이트하려 했기 때문입니다.
- **해결**:
  - `AuthProvider`와 UI 로직을 분리하여, 로그아웃 시 **화면 전환(Navigation)을 먼저 수행**하고, 이후에 데이터 초기화를 진행하도록 순서를 변경했습니다.
  - `mounted` 속성을 확인하는 방어 코드를 추가하여 안정성을 확보했습니다.

### 4. 회원가입 UX 개선
- **문제**: 회원가입 후 다시 로그인을 해야 하는 번거로운 절차가 있었습니다.
- **해결**: 회원가입 API 호출 성공 시, 내부적으로 로그인 로직을 연이어 실행하도록 `AuthProvider`를 개선하여, 사용자가 가입 즉시 서비스에 진입할 수 있도록 UX를 개선했습니다.

---

## 🛠 Tech Stack

### Backend
- **Language**: Java 17
- **Framework**: Spring Boot 3.x
- **Database**: PostgreSQL (JPA/Hibernate)
- **Security**: Spring Security, JWT (Access Token), BCrypt
- **AI**: Google Gemini Pro API
- **Scheduler**: ShedLock (분산 환경 스케줄링 고려)

### Frontend
- **Framework**: Flutter
- **State Management**: Provider
- **Network**: Dio (with Interceptors for Auth)
- **UI**: Material Design 3

### Infrastructure
- **Deployment**: Railway (Docker)
- **Store**: ONE Store (Android)
- **CI/CD**: GitHub Actions (예정)

---

## 🏗 System Architecture

### AI Feedback Process (Async + Polling)

1. **Submit**: 사용자 저널 제출 → DB 저장 → `201 Created` 즉시 응답.
2. **Async Processing**: 백엔드 `@Async` 스레드에서 Gemini API 호출 및 프롬프트 엔지니어링 수행.
3. **Polling**: 프론트엔드에서 3초 간격으로 피드백 생성 여부 확인 (`GET /log/latest`).
4. **Complete**: AI 피드백 생성 완료 시 DB 업데이트 → 프론트엔드에 데이터 전달.

---

## 📂 Project Structure

```
justaday/
├── backend/            # Spring Boot Server
│   ├── src/main/java/io/github/jahee24/justaday/
│   │   ├── controller  # API Endpoints
│   │   ├── service     # Business Logic (AI Pipeline, Auth)
│   │   ├── entity      # JPA Entities (User, JournalLog, AIFeedback)
│   │   ├── scheduler   # Daily Summary Task
│   │   └── config      # Security, Async Config
│   └── build.gradle
│
└── frontend/           # Flutter App
    ├── lib/
    │   ├── ui/         # Screens (Journal, Auth, Persona, Settings)
    │   ├── state/      # Providers (JournalProvider, AuthProvider)
    │   ├── data/       # API Clients & Models
    │   └── main.dart
    └── pubspec.yaml
```

---

## 📝 API Overview

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/api/v1/auth/signup` | 회원가입 |
| `POST` | `/api/v1/auth/login` | 로그인 (JWT 발급) |
| `DELETE`| `/api/v1/user` | 회원 탈퇴 (관련 데이터 일괄 삭제) |
| `POST` | `/api/v1/log` | 저널 제출 (AI 분석 시작) |
| `GET` | `/api/v1/log/latest` | 오늘의 저널 및 피드백 조회 (Polling용) |
| `GET` | `/api/v1/log/getall` | 전체 기록 조회 |
| `GET` | `/api/v1/personas` | 선택 가능한 페르소나 목록 조회 |

---

## 👨‍💻 Developer
- **Hee** (Full Stack Developer)
- **Contact**: jahee24.dev@gmail.com
