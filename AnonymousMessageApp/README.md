# Anonymous Message App

익명 쪽지를 주고받을 수 있는 iOS 앱입니다.

## 프로젝트 개요

사용자가 직접 말하기 어려웠던 질문이나 메시지를 익명 또는 실명으로 전달하고, 수신자가 답변할 수 있는 소통 플랫폼입니다.

## 기술 스택

- **언어**: Swift
- **UI 프레임워크**: SwiftUI
- **아키텍처**: Clean Architecture + TCA (The Composable Architecture)
- **최소 지원 버전**: iOS 16.0+

## 아키텍처

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

## 주요 기능

### 핵심 기능
- 🔐 회원가입 및 로그인
- 👥 연락처 관리 (최대 5명)
- 📝 익명/실명 쪽지 발송
- 🔗 링크 기반 쪽지 수신 및 답변
- 📚 쪽지 히스토리 관리

### 비즈니스 규칙
- 연락처는 등록 후 3일간 삭제 불가
- 무료 사용자는 최대 5명까지 연락처 등록 가능
- 프리미엄 사용자는 무제한 연락처 등록 (향후 구현)

## 프로젝트 구조

### Domain Layer (✅ 완료)
```
Domain/
├── Entities/
│   ├── User.swift
│   ├── Contact.swift
│   ├── Message.swift
│   ├── Answer.swift
│   └── MessageStatus.swift
│
├── ValueObjects/
│   ├── PersonalLink.swift
│   └── ContactLimit.swift
│
├── RepositoryInterfaces/
│   ├── UserRepositoryInterface.swift
│   ├── ContactRepositoryInterface.swift
│   ├── MessageRepositoryInterface.swift
│   └── AuthRepositoryInterface.swift
│
└── UseCases/
    ├── Auth/
    │   ├── LoginUseCase.swift
    │   ├── SignupUseCase.swift
    │   └── LogoutUseCase.swift
    │
    ├── Contact/
    │   ├── AddContactUseCase.swift
    │   ├── DeleteContactUseCase.swift
    │   ├── FetchContactsUseCase.swift
    │   └── UpdateContactUseCase.swift
    │
    ├── Message/
    │   ├── SendMessageUseCase.swift
    │   ├── AnswerMessageUseCase.swift
    │   └── FetchMessageHistoryUseCase.swift
    │
    └── User/
        ├── FetchUserProfileUseCase.swift
        └── UpdateUserProfileUseCase.swift
```

### Data Layer (🚧 진행 예정)
- Repositories
- Data Sources (Remote/Local)
- DTOs
- Mappers

### Presentation Layer (🚧 진행 예정)
- TCA Features
- SwiftUI Views
- Components

## 개발 로드맵

### Phase 1: MVP (현재)
- [x] PRD 작성
- [x] 아키텍처 설계
- [x] Domain Layer 구현
- [ ] Data Layer 구현
- [ ] Presentation Layer 구현
- [ ] 기본 기능 통합

### Phase 2: 개선
- [ ] UI/UX 개선
- [ ] 성능 최적화
- [ ] 테스트 코드 작성

### Phase 3: 확장
- [ ] 유료 구독 시스템
- [ ] 푸시 알림
- [ ] 이미지 첨부 기능

## 문서

- [PRD (Product Requirements Document)](docs/PRD_Anonymous_Message_App.md)
- [Architecture Design Document](docs/Architecture_Design.md)

## 라이선스

MIT License

## 작성자

Anonymous Message Team
