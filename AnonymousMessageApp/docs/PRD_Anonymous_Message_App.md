# Product Requirements Document (PRD)
# 익명 쪽지 앱 (Anonymous Message App)

## 1. 제품 개요

### 1.1 제품 비전
사용자가 직접 말하기 어려웠던 질문이나 메시지를 익명 또는 실명으로 전달하고, 수신자가 답변할 수 있는 소통 플랫폼

### 1.2 핵심 가치 제안
- 익명성을 통한 솔직한 소통
- 링크 공유만으로 접근 가능한 간편함
- 주고받은 쪽지의 체계적인 관리

---

## 2. 기능 요구사항

### 2.1 핵심 기능

#### 2.1.1 사용자 관리
- **회원가입/로그인**: 기본 인증 시스템
- **프로필 설정**: 사용자 기본 정보 관리
- **개인 링크 생성**: 쪽지 수신용 고유 링크 자동 생성

#### 2.1.2 연락처 관리
- **연락처 등록**: 쪽지를 보낼 대상 등록 (최대 5명)
  - 이름, 관계, 메모 등 기본 정보 입력
  - 등록 시점 기록
- **등록 제한**: 
  - 동시 등록 가능 인원: 5명
  - 삭제 제한 기간: 등록 후 3일간 삭제 불가
  - 제한 해제 조건: 향후 유료 결제 시스템 도입 예정
- **연락처 관리**:
  - 연락처 목록 조회
  - 연락처 상세 정보 보기
  - 삭제 가능 기간 경과 시 삭제

#### 2.1.3 쪽지 발송
- **쪽지 작성**:
  - 등록된 연락처 선택
  - 질문/메시지 내용 작성 (텍스트)
  - 발송 방식 선택: 익명 / 실명
- **쪽지 전송**:
  - 수신자 링크로 전송
  - 알림 옵션 (푸시, 이메일 등 - 추후 확장)

#### 2.1.4 쪽지 수신 및 답변
- **링크 기반 접근**:
  - 웹 브라우저에서 즉시 확인 가능
  - 앱 설치 유도 (선택사항)
- **쪽지 확인**:
  - 받은 쪽지 목록 조회
  - 발신자 정보 표시 (익명 여부에 따라)
  - 발송 시간 표시
- **답변 작성**:
  - 쪽지별 답변 작성
  - 답변 전송

#### 2.1.5 쪽지 히스토리
- **전체 히스토리**:
  - 보낸 쪽지 목록
  - 받은 쪽지 목록
  - 답변 완료/미완료 상태 표시
- **연락처별 히스토리**:
  - 특정 연락처와 주고받은 모든 쪽지
  - 시간순 정렬
  - 쪽지 내용 및 답변 전체 조회
- **검색 및 필터링**:
  - 날짜별 필터
  - 답변 상태별 필터
  - 익명/실명 필터

### 2.2 부가 기능 (추후 확장)
- 유료 구독 시스템
- 연락처 제한 해제
- 푸시 알림
- 이메일 알림
- 쪽지 템플릿
- 이미지 첨부

---

## 3. 기술 스택

### 3.1 Frontend
- **프레임워크**: SwiftUI
- **아키텍처**: TCA (The Composable Architecture)
- **디자인 패턴**: Clean Architecture

### 3.2 아키텍처 구조

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (SwiftUI Views + TCA Features)         │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│          Domain Layer                   │
│  (Entities, Use Cases, Protocols)       │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│           Data Layer                    │
│  (Repositories, Data Sources, DTOs)     │
└─────────────────────────────────────────┘
```

#### 3.2.1 Layer 구성

**Presentation Layer**
- TCA Feature 모듈
  - State, Action, Reducer 정의
  - View와 1:1 매핑
- SwiftUI Views
  - UI 렌더링
  - 사용자 상호작용 처리

**Domain Layer**
- Entities: 비즈니스 핵심 모델
  - User, Contact, Message, Answer
- Use Cases: 비즈니스 로직
  - SendMessageUseCase
  - AnswerMessageUseCase
  - ManageContactsUseCase
  - FetchMessageHistoryUseCase
- Repository Protocols: 데이터 접근 인터페이스

**Data Layer**
- Repository Implementations
- Data Sources (Local/Remote)
- DTOs (Data Transfer Objects)
- API Clients
- Database Managers

### 3.3 의존성 관리
- **의존성 방향**: Presentation → Domain ← Data
- **의존성 역전**: Protocol을 통한 추상화
- **의존성 주입**: 
  - TCA의 Dependencies 활용
  - Protocol 기반 Mock 지원

---

## 4. 데이터 모델

### 4.1 핵심 엔티티

#### User (사용자)
```swift
struct User {
    let id: UUID
    let username: String
    let email: String
    let profileImageURL: URL?
    let personalLink: String // 쪽지 수신용 고유 링크
    let createdAt: Date
}
```

#### Contact (연락처)
```swift
struct Contact {
    let id: UUID
    let ownerUserId: UUID
    let name: String
    let relationship: String?
    let memo: String?
    let registeredAt: Date
    let deletableAt: Date // registeredAt + 3일
    var isDeletable: Bool // 삭제 가능 여부
}
```

#### Message (쪽지)
```swift
struct Message {
    let id: UUID
    let senderId: UUID
    let receiverId: UUID
    let contactId: UUID? // 발신자의 연락처 참조
    let content: String
    let isAnonymous: Bool
    let sentAt: Date
    var answer: Answer?
    var status: MessageStatus // pending, answered
}

enum MessageStatus {
    case pending
    case answered
}
```

#### Answer (답변)
```swift
struct Answer {
    let id: UUID
    let messageId: UUID
    let content: String
    let answeredAt: Date
}
```

### 4.2 비즈니스 규칙

#### 연락처 제한
```swift
struct ContactLimit {
    static let maxFreeContacts = 5
    static let deletionLockPeriod: TimeInterval = 3 * 24 * 60 * 60 // 3일
    
    func canAddContact(currentCount: Int, isPremium: Bool) -> Bool
    func canDeleteContact(contact: Contact) -> Bool
}
```

---

## 5. 사용자 플로우

### 5.1 쪽지 발송 플로우
```
1. 앱 실행 및 로그인
2. 연락처 목록 조회
3. 연락처 선택 (또는 새 연락처 등록)
4. 쪽지 작성
5. 익명/실명 선택
6. 발송
7. 발송 완료 확인
```

### 5.2 쪽지 수신 및 답변 플로우
```
1. 링크 수신 (SMS, 메신저 등)
2. 링크 클릭 → 웹 또는 앱으로 이동
3. 쪽지 내용 확인
4. 답변 작성
5. 답변 전송
6. 완료 메시지 표시
```

### 5.3 히스토리 조회 플로우
```
1. 히스토리 탭 선택
2. 보낸 쪽지/받은 쪽지 선택
3. 목록 조회
4. 특정 쪽지 선택
5. 상세 내용 및 답변 확인
```

---

## 6. UI/UX 요구사항

### 6.1 주요 화면

#### 6.1.1 홈 화면
- 연락처 목록 (최대 5개)
- 빠른 쪽지 작성 버튼
- 받은 쪽지 알림 배지

#### 6.1.2 연락처 관리 화면
- 연락처 카드 리스트
- 각 카드에 삭제 가능 여부 표시
- 등록/삭제 버튼

#### 6.1.3 쪽지 작성 화면
- 수신자 선택
- 메시지 입력 필드
- 익명/실명 토글
- 전송 버튼

#### 6.1.4 히스토리 화면
- 탭: 보낸 쪽지 / 받은 쪽지
- 리스트: 시간순 정렬
- 필터 옵션
- 검색 기능

#### 6.1.5 쪽지 상세 화면
- 발신자 정보 (익명일 경우 "익명" 표시)
- 쪽지 내용
- 답변 내용 (있을 경우)
- 타임스탬프

#### 6.1.6 링크 접속 화면 (웹/앱)
- 쪽지 내용 표시
- 답변 입력 필드
- 답변 전송 버튼
- 앱 다운로드 유도 (웹인 경우)

### 6.2 디자인 원칙
- 심플하고 직관적인 UI
- 쪽지 특성을 살린 따뜻한 디자인
- 익명성을 시각적으로 표현
- 접근성 고려 (다크모드, 폰트 크기 등)

---

## 7. 비기능 요구사항

### 7.1 성능
- 앱 실행 시간: 3초 이내
- 쪽지 로딩 시간: 1초 이내
- 오프라인 지원: 로컬 캐싱

### 7.2 보안
- 사용자 인증 및 인가
- 데이터 암호화 (전송 및 저장)
- 익명 쪽지의 발신자 정보 보호

### 7.3 확장성
- 유료 구독 시스템 도입 대비
- 알림 시스템 확장 대비
- 멀티미디어 첨부 기능 확장 대비

### 7.4 유지보수성
- 클린 아키텍처를 통한 관심사 분리
- TCA를 통한 테스트 용이성
- 명확한 책임 분리

---

## 8. 개발 단계

### Phase 1: MVP (Minimum Viable Product)
- 기본 인증 시스템
- 연락처 관리 (최대 5명, 3일 삭제 제한)
- 쪽지 발송 (익명/실명)
- 링크 기반 쪽지 수신 및 답변
- 기본 히스토리 조회

### Phase 2: 개선
- UI/UX 개선
- 검색 및 필터링 강화
- 성능 최적화
- 버그 수정

### Phase 3: 확장
- 유료 구독 시스템
- 푸시 알림
- 이미지 첨부
- 추가 커스터마이징 옵션

---

## 9. 기술적 고려사항

### 9.1 TCA 구조 설계

#### Feature 모듈화
```
Features/
├── Root/
├── Auth/
│   ├── Login/
│   └── Signup/
├── Contact/
│   ├── ContactList/
│   ├── ContactDetail/
│   └── ContactForm/
├── Message/
│   ├── MessageCompose/
│   ├── MessageDetail/
│   └── MessageHistory/
└── Profile/
```

#### State 관리
- 각 Feature별 독립적인 State
- Shared State는 Root에서 관리
- State 변화는 Reducer를 통해서만 발생

#### Effect 처리
- Use Case를 Effect로 래핑
- 비동기 작업 처리
- 에러 핸들링

### 9.2 Clean Architecture 적용

#### 계층별 책임

**Presentation**
- UI 렌더링
- 사용자 입력 처리
- TCA Feature 로직

**Domain**
- 비즈니스 규칙
- 엔티티 정의
- Use Case 구현

**Data**
- 데이터 소스 관리
- API 통신
- 로컬 저장소 관리
- DTO ↔ Entity 변환

#### 의존성 규칙
```
Presentation -> Domain <- Data
     ↓            ↓         ↓
  Views      Use Cases  Repositories
     ↓            ↓         ↓
 TCA State   Entities   Data Sources
```

### 9.3 테스트 전략

#### Unit Tests
- Use Case 테스트
- Reducer 테스트
- Repository 테스트

#### Integration Tests
- Feature 통합 테스트
- 데이터 플로우 테스트

#### UI Tests
- 주요 사용자 플로우 테스트

---

## 10. 성공 지표

### 10.1 사용자 지표
- DAU (Daily Active Users)
- 평균 쪽지 발송 수
- 답변율

### 10.2 기술 지표
- 앱 크래시율 < 1%
- API 응답 시간 < 500ms
- 사용자 유지율

### 10.3 비즈니스 지표 (향후)
- 유료 전환율
- ARPU (Average Revenue Per User)

---

## 11. 리스크 및 대응

### 11.1 기술적 리스크
- **리스크**: TCA 학습 곡선
  - **대응**: 단계적 도입, 문서화 강화
- **리스크**: 성능 이슈
  - **대응**: 프로파일링, 최적화

### 11.2 비즈니스 리스크
- **리스크**: 악의적 사용 (스팸, 괴롭힘)
  - **대응**: 신고 기능, 차단 기능, 모니터링
- **리스크**: 사용자 확보 어려움
  - **대응**: 명확한 가치 제안, 마케팅 전략

---

## 12. 향후 로드맵

### 12.1 단기 (3개월)
- MVP 개발 완료
- 베타 테스트
- 초기 사용자 피드백 수집

### 12.2 중기 (6개월)
- 정식 출시
- 유료 구독 시스템 도입
- 기능 확장

### 12.3 장기 (1년)
- 커뮤니티 기능 추가
- 다국어 지원
- 크로스 플랫폼 확장 (Android)

---

## 부록

### A. 용어 정의
- **쪽지**: 사용자 간 주고받는 메시지
- **연락처**: 쪽지를 보낼 대상으로 등록된 사람
- **익명 쪽지**: 발신자 정보가 숨겨진 쪽지
- **실명 쪽지**: 발신자 정보가 공개된 쪽지
- **개인 링크**: 각 사용자가 쪽지를 받을 수 있는 고유 URL

### B. 참고 자료
- TCA 공식 문서: https://github.com/pointfreeco/swift-composable-architecture
- Clean Architecture: Robert C. Martin
- SwiftUI 공식 문서: https://developer.apple.com/documentation/swiftui

---

**문서 버전**: 1.0  
**작성일**: 2025-12-05  
**최종 수정일**: 2025-12-05  
**작성자**: Product Team
