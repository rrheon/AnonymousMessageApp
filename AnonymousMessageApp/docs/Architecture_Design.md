# Architecture Design Document
# 익명 쪽지 앱 - 상세 아키텍처 설계

## 1. 전체 아키텍처 개요

### 1.1 Clean Architecture + TCA 통합

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Feature    │  │   Feature    │  │   Feature    │      │
│  │   Module     │  │   Module     │  │   Module     │      │
│  │              │  │              │  │              │      │
│  │ State/Action │  │ State/Action │  │ State/Action │      │
│  │   Reducer    │  │   Reducer    │  │   Reducer    │      │
│  │    View      │  │    View      │  │    View      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Entities   │  │  Use Cases   │  │  Protocols   │      │
│  │              │  │              │  │              │      │
│  │  User        │  │  SendMessage │  │  Repository  │      │
│  │  Contact     │  │  ManageContac│  │  Interfaces  │      │
│  │  Message     │  │  FetchHistory│  │              │      │
│  │  Answer      │  │  etc...      │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Repositories │  │ Data Sources │  │     DTOs     │      │
│  │              │  │              │  │              │      │
│  │ UserRepo     │  │  Remote API  │  │  UserDTO     │      │
│  │ ContactRepo  │  │  Local DB    │  │  MessageDTO  │      │
│  │ MessageRepo  │  │  UserDefaults│  │  etc...      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 의존성 방향 규칙

```
Presentation Layer
    │ (depends on)
    ↓
Domain Layer (Interfaces/Protocols)
    ↑ (implements)
    │
Data Layer
```

**핵심 원칙:**
- Presentation은 Domain의 Use Case와 Entity만 알고 있음
- Domain은 어떤 Layer에도 의존하지 않음 (순수 비즈니스 로직)
- Data는 Domain의 Protocol을 구현함
- 의존성 주입은 TCA의 Dependencies를 활용

---

## 2. 프로젝트 구조

### 2.1 디렉토리 구조

```
AnonymousMessageApp/
├── App/
│   ├── AnonymousMessageApp.swift
│   └── AppDelegate.swift
│
├── Domain/
│   ├── Entities/
│   │   ├── User.swift
│   │   ├── Contact.swift
│   │   ├── Message.swift
│   │   ├── Answer.swift
│   │   └── MessageStatus.swift
│   │
│   ├── UseCases/
│   │   ├── Auth/
│   │   │   ├── LoginUseCase.swift
│   │   │   ├── SignupUseCase.swift
│   │   │   └── LogoutUseCase.swift
│   │   │
│   │   ├── Contact/
│   │   │   ├── AddContactUseCase.swift
│   │   │   ├── DeleteContactUseCase.swift
│   │   │   ├── FetchContactsUseCase.swift
│   │   │   └── ValidateContactLimitUseCase.swift
│   │   │
│   │   ├── Message/
│   │   │   ├── SendMessageUseCase.swift
│   │   │   ├── FetchMessagesUseCase.swift
│   │   │   ├── AnswerMessageUseCase.swift
│   │   │   └── FetchMessageHistoryUseCase.swift
│   │   │
│   │   └── User/
│   │       ├── FetchUserProfileUseCase.swift
│   │       └── UpdateUserProfileUseCase.swift
│   │
│   ├── RepositoryInterfaces/
│   │   ├── UserRepositoryInterface.swift
│   │   ├── ContactRepositoryInterface.swift
│   │   ├── MessageRepositoryInterface.swift
│   │   └── AuthRepositoryInterface.swift
│   │
│   └── ValueObjects/
│       ├── ContactLimit.swift
│       └── PersonalLink.swift
│
├── Data/
│   ├── Repositories/
│   │   ├── UserRepository.swift
│   │   ├── ContactRepository.swift
│   │   ├── MessageRepository.swift
│   │   └── AuthRepository.swift
│   │
│   ├── DataSources/
│   │   ├── Remote/
│   │   │   ├── API/
│   │   │   │   ├── APIClient.swift
│   │   │   │   ├── APIEndpoint.swift
│   │   │   │   └── APIError.swift
│   │   │   │
│   │   │   └── Services/
│   │   │       ├── UserAPIService.swift
│   │   │       ├── ContactAPIService.swift
│   │   │       └── MessageAPIService.swift
│   │   │
│   │   └── Local/
│   │       ├── Database/
│   │       │   ├── CoreDataStack.swift
│   │       │   ├── ContactEntity+CoreData.swift
│   │       │   ├── MessageEntity+CoreData.swift
│   │       │   └── UserEntity+CoreData.swift
│   │       │
│   │       └── UserDefaults/
│   │           └── UserDefaultsManager.swift
│   │
│   ├── DTOs/
│   │   ├── UserDTO.swift
│   │   ├── ContactDTO.swift
│   │   ├── MessageDTO.swift
│   │   └── AnswerDTO.swift
│   │
│   └── Mappers/
│       ├── UserMapper.swift
│       ├── ContactMapper.swift
│       ├── MessageMapper.swift
│       └── AnswerMapper.swift
│
├── Presentation/
│   ├── Features/
│   │   ├── Root/
│   │   │   ├── RootFeature.swift
│   │   │   └── RootView.swift
│   │   │
│   │   ├── Auth/
│   │   │   ├── Login/
│   │   │   │   ├── LoginFeature.swift
│   │   │   │   └── LoginView.swift
│   │   │   │
│   │   │   └── Signup/
│   │   │       ├── SignupFeature.swift
│   │   │       └── SignupView.swift
│   │   │
│   │   ├── Home/
│   │   │   ├── HomeFeature.swift
│   │   │   └── HomeView.swift
│   │   │
│   │   ├── Contact/
│   │   │   ├── ContactList/
│   │   │   │   ├── ContactListFeature.swift
│   │   │   │   └── ContactListView.swift
│   │   │   │
│   │   │   ├── ContactDetail/
│   │   │   │   ├── ContactDetailFeature.swift
│   │   │   │   └── ContactDetailView.swift
│   │   │   │
│   │   │   └── ContactForm/
│   │   │       ├── ContactFormFeature.swift
│   │   │       └── ContactFormView.swift
│   │   │
│   │   ├── Message/
│   │   │   ├── MessageCompose/
│   │   │   │   ├── MessageComposeFeature.swift
│   │   │   │   └── MessageComposeView.swift
│   │   │   │
│   │   │   ├── MessageDetail/
│   │   │   │   ├── MessageDetailFeature.swift
│   │   │   │   └── MessageDetailView.swift
│   │   │   │
│   │   │   ├── MessageHistory/
│   │   │   │   ├── MessageHistoryFeature.swift
│   │   │   │   └── MessageHistoryView.swift
│   │   │   │
│   │   │   └── MessageReceive/
│   │   │       ├── MessageReceiveFeature.swift
│   │   │       └── MessageReceiveView.swift
│   │   │
│   │   └── Profile/
│   │       ├── ProfileFeature.swift
│   │       └── ProfileView.swift
│   │
│   ├── Components/
│   │   ├── Buttons/
│   │   ├── Cards/
│   │   ├── TextFields/
│   │   └── Loading/
│   │
│   └── Utilities/
│       ├── Extensions/
│       └── Modifiers/
│
├── Core/
│   ├── DependencyInjection/
│   │   ├── DependencyKey.swift
│   │   └── DependencyValues+Extensions.swift
│   │
│   ├── Networking/
│   │   ├── NetworkMonitor.swift
│   │   └── URLSession+Extensions.swift
│   │
│   └── Storage/
│       └── KeychainManager.swift
│
├── Resources/
│   ├── Assets.xcassets/
│   ├── Localizations/
│   └── Fonts/
│
└── Tests/
    ├── DomainTests/
    │   ├── UseCaseTests/
    │   └── EntityTests/
    │
    ├── DataTests/
    │   ├── RepositoryTests/
    │   └── MapperTests/
    │
    └── PresentationTests/
        └── FeatureTests/
```

---

## 3. Layer별 상세 설계

### 3.1 Domain Layer

#### 3.1.1 Entities

**User.swift**
```swift
import Foundation

struct User: Equatable, Identifiable {
    let id: UUID
    let username: String
    let email: String
    let profileImageURL: URL?
    let personalLink: PersonalLink
    let createdAt: Date
    
    var displayName: String {
        username
    }
}
```

**Contact.swift**
```swift
import Foundation

struct Contact: Equatable, Identifiable {
    let id: UUID
    let ownerUserId: UUID
    let name: String
    let relationship: String?
    let memo: String?
    let registeredAt: Date
    
    var deletableAt: Date {
        registeredAt.addingTimeInterval(ContactLimit.deletionLockPeriod)
    }
    
    var isDeletable: Bool {
        Date() >= deletableAt
    }
    
    var remainingLockDays: Int {
        let remaining = deletableAt.timeIntervalSince(Date())
        return max(0, Int(ceil(remaining / (24 * 60 * 60))))
    }
}
```

**Message.swift**
```swift
import Foundation

struct Message: Equatable, Identifiable {
    let id: UUID
    let senderId: UUID
    let receiverId: UUID
    let contactId: UUID?
    let content: String
    let isAnonymous: Bool
    let sentAt: Date
    var answer: Answer?
    
    var status: MessageStatus {
        answer == nil ? .pending : .answered
    }
    
    var displaySenderName: String {
        isAnonymous ? "익명" : "알 수 없음"
    }
}
```

**Answer.swift**
```swift
import Foundation

struct Answer: Equatable, Identifiable {
    let id: UUID
    let messageId: UUID
    let content: String
    let answeredAt: Date
}
```

**MessageStatus.swift**
```swift
enum MessageStatus: String, Equatable {
    case pending = "pending"
    case answered = "answered"
}
```

#### 3.1.2 Value Objects

**ContactLimit.swift**
```swift
import Foundation

struct ContactLimit {
    static let maxFreeContacts = 5
    static let deletionLockPeriod: TimeInterval = 3 * 24 * 60 * 60 // 3일
    
    let currentCount: Int
    let isPremium: Bool
    
    var maxContacts: Int {
        isPremium ? .max : Self.maxFreeContacts
    }
    
    var canAddContact: Bool {
        currentCount < maxContacts
    }
    
    var remainingSlots: Int {
        max(0, maxContacts - currentCount)
    }
    
    func canDeleteContact(_ contact: Contact) -> Bool {
        contact.isDeletable
    }
}
```

**PersonalLink.swift**
```swift
import Foundation

struct PersonalLink: Equatable {
    let userId: UUID
    let token: String
    
    var url: URL {
        URL(string: "https://app.anonymous-message.com/receive/\(token)")!
    }
    
    var shareableText: String {
        "익명으로 쪽지를 보내주세요: \(url.absoluteString)"
    }
}
```

#### 3.1.3 Repository Interfaces

**UserRepositoryInterface.swift**
```swift
import Foundation

protocol UserRepositoryInterface {
    func fetchCurrentUser() async throws -> User
    func updateUser(_ user: User) async throws -> User
    func fetchUser(byId id: UUID) async throws -> User
    func fetchUser(byPersonalLink link: String) async throws -> User
}
```

**ContactRepositoryInterface.swift**
```swift
import Foundation

protocol ContactRepositoryInterface {
    func fetchContacts(forUserId userId: UUID) async throws -> [Contact]
    func fetchContact(byId id: UUID) async throws -> Contact
    func addContact(_ contact: Contact) async throws -> Contact
    func deleteContact(byId id: UUID) async throws
    func updateContact(_ contact: Contact) async throws -> Contact
}
```

**MessageRepositoryInterface.swift**
```swift
import Foundation

protocol MessageRepositoryInterface {
    func sendMessage(_ message: Message) async throws -> Message
    func fetchSentMessages(forUserId userId: UUID) async throws -> [Message]
    func fetchReceivedMessages(forUserId userId: UUID) async throws -> [Message]
    func fetchMessage(byId id: UUID) async throws -> Message
    func fetchMessagesForContact(contactId: UUID) async throws -> [Message]
    func answerMessage(messageId: UUID, answer: Answer) async throws -> Message
}
```

**AuthRepositoryInterface.swift**
```swift
import Foundation

protocol AuthRepositoryInterface {
    func login(email: String, password: String) async throws -> User
    func signup(username: String, email: String, password: String) async throws -> User
    func logout() async throws
    func getCurrentUser() async throws -> User?
}
```

#### 3.1.4 Use Cases

**SendMessageUseCase.swift**
```swift
import Foundation

struct SendMessageUseCase {
    private let messageRepository: MessageRepositoryInterface
    private let contactRepository: ContactRepositoryInterface
    
    init(
        messageRepository: MessageRepositoryInterface,
        contactRepository: ContactRepositoryInterface
    ) {
        self.messageRepository = messageRepository
        self.contactRepository = contactRepository
    }
    
    func execute(
        senderId: UUID,
        contactId: UUID,
        content: String,
        isAnonymous: Bool
    ) async throws -> Message {
        // 1. 연락처 유효성 검증
        let contact = try await contactRepository.fetchContact(byId: contactId)
        
        // 2. 메시지 생성
        let message = Message(
            id: UUID(),
            senderId: senderId,
            receiverId: contact.ownerUserId,
            contactId: contactId,
            content: content,
            isAnonymous: isAnonymous,
            sentAt: Date(),
            answer: nil
        )
        
        // 3. 메시지 전송
        return try await messageRepository.sendMessage(message)
    }
}
```

**AddContactUseCase.swift**
```swift
import Foundation

enum ContactError: Error {
    case limitReached
    case duplicateName
}

struct AddContactUseCase {
    private let contactRepository: ContactRepositoryInterface
    
    init(contactRepository: ContactRepositoryInterface) {
        self.contactRepository = contactRepository
    }
    
    func execute(
        ownerUserId: UUID,
        name: String,
        relationship: String?,
        memo: String?,
        isPremium: Bool
    ) async throws -> Contact {
        // 1. 현재 연락처 개수 확인
        let currentContacts = try await contactRepository.fetchContacts(forUserId: ownerUserId)
        let contactLimit = ContactLimit(currentCount: currentContacts.count, isPremium: isPremium)
        
        // 2. 추가 가능 여부 검증
        guard contactLimit.canAddContact else {
            throw ContactError.limitReached
        }
        
        // 3. 중복 이름 검증
        if currentContacts.contains(where: { $0.name == name }) {
            throw ContactError.duplicateName
        }
        
        // 4. 연락처 생성 및 저장
        let contact = Contact(
            id: UUID(),
            ownerUserId: ownerUserId,
            name: name,
            relationship: relationship,
            memo: memo,
            registeredAt: Date()
        )
        
        return try await contactRepository.addContact(contact)
    }
}
```

**DeleteContactUseCase.swift**
```swift
import Foundation

enum DeleteContactError: Error {
    case contactLocked(remainingDays: Int)
}

struct DeleteContactUseCase {
    private let contactRepository: ContactRepositoryInterface
    
    init(contactRepository: ContactRepositoryInterface) {
        self.contactRepository = contactRepository
    }
    
    func execute(contactId: UUID) async throws {
        // 1. 연락처 조회
        let contact = try await contactRepository.fetchContact(byId: contactId)
        
        // 2. 삭제 가능 여부 검증
        guard contact.isDeletable else {
            throw DeleteContactError.contactLocked(remainingDays: contact.remainingLockDays)
        }
        
        // 3. 삭제 실행
        try await contactRepository.deleteContact(byId: contactId)
    }
}
```

**FetchMessageHistoryUseCase.swift**
```swift
import Foundation

enum HistoryType {
    case sent
    case received
    case forContact(UUID)
}

struct FetchMessageHistoryUseCase {
    private let messageRepository: MessageRepositoryInterface
    
    init(messageRepository: MessageRepositoryInterface) {
        self.messageRepository = messageRepository
    }
    
    func execute(userId: UUID, type: HistoryType) async throws -> [Message] {
        let messages: [Message]
        
        switch type {
        case .sent:
            messages = try await messageRepository.fetchSentMessages(forUserId: userId)
        case .received:
            messages = try await messageRepository.fetchReceivedMessages(forUserId: userId)
        case .forContact(let contactId):
            messages = try await messageRepository.fetchMessagesForContact(contactId: contactId)
        }
        
        // 최신순 정렬
        return messages.sorted { $0.sentAt > $1.sentAt }
    }
}
```

---

### 3.2 Data Layer

#### 3.2.1 DTOs

**UserDTO.swift**
```swift
import Foundation

struct UserDTO: Codable {
    let id: String
    let username: String
    let email: String
    let profileImageURL: String?
    let personalLinkToken: String
    let createdAt: String
}
```

**ContactDTO.swift**
```swift
import Foundation

struct ContactDTO: Codable {
    let id: String
    let ownerUserId: String
    let name: String
    let relationship: String?
    let memo: String?
    let registeredAt: String
}
```

**MessageDTO.swift**
```swift
import Foundation

struct MessageDTO: Codable {
    let id: String
    let senderId: String
    let receiverId: String
    let contactId: String?
    let content: String
    let isAnonymous: Bool
    let sentAt: String
    let answer: AnswerDTO?
}
```

**AnswerDTO.swift**
```swift
import Foundation

struct AnswerDTO: Codable {
    let id: String
    let messageId: String
    let content: String
    let answeredAt: String
}
```

#### 3.2.2 Mappers

**UserMapper.swift**
```swift
import Foundation

struct UserMapper {
    static func toDomain(_ dto: UserDTO) -> User {
        User(
            id: UUID(uuidString: dto.id) ?? UUID(),
            username: dto.username,
            email: dto.email,
            profileImageURL: dto.profileImageURL.flatMap { URL(string: $0) },
            personalLink: PersonalLink(
                userId: UUID(uuidString: dto.id) ?? UUID(),
                token: dto.personalLinkToken
            ),
            createdAt: ISO8601DateFormatter().date(from: dto.createdAt) ?? Date()
        )
    }
    
    static func toDTO(_ domain: User) -> UserDTO {
        UserDTO(
            id: domain.id.uuidString,
            username: domain.username,
            email: domain.email,
            profileImageURL: domain.profileImageURL?.absoluteString,
            personalLinkToken: domain.personalLink.token,
            createdAt: ISO8601DateFormatter().string(from: domain.createdAt)
        )
    }
}
```

#### 3.2.3 Repositories

**MessageRepository.swift**
```swift
import Foundation

final class MessageRepository: MessageRepositoryInterface {
    private let remoteDataSource: MessageAPIService
    private let localDataSource: MessageLocalDataSource
    
    init(
        remoteDataSource: MessageAPIService,
        localDataSource: MessageLocalDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func sendMessage(_ message: Message) async throws -> Message {
        let dto = MessageMapper.toDTO(message)
        let resultDTO = try await remoteDataSource.sendMessage(dto)
        let result = MessageMapper.toDomain(resultDTO)
        
        // 로컬 캐싱
        try await localDataSource.saveMessage(result)
        
        return result
    }
    
    func fetchSentMessages(forUserId userId: UUID) async throws -> [Message] {
        // 네트워크 확인
        if NetworkMonitor.shared.isConnected {
            let dtos = try await remoteDataSource.fetchSentMessages(userId: userId.uuidString)
            let messages = dtos.map { MessageMapper.toDomain($0) }
            
            // 로컬 캐싱
            try await localDataSource.saveMessages(messages)
            
            return messages
        } else {
            // 오프라인: 로컬 데이터 반환
            return try await localDataSource.fetchSentMessages(forUserId: userId)
        }
    }
    
    // 나머지 메서드들...
}
```

---

### 3.3 Presentation Layer (TCA)

#### 3.3.1 Feature 구조

**ContactListFeature.swift**
```swift
import ComposableArchitecture
import Foundation

@Reducer
struct ContactListFeature {
    @ObservableState
    struct State: Equatable {
        var contacts: [Contact] = []
        var isLoading = false
        var error: String?
        var contactLimit: ContactLimit?
        var showingAddContact = false
        
        @Presents var destination: Destination.State?
    }
    
    enum Action {
        case onAppear
        case contactsResponse(Result<[Contact], Error>)
        case deleteContactTapped(Contact)
        case deleteContactResponse(Result<Void, Error>)
        case addContactTapped
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Dependency(\.fetchContactsUseCase) var fetchContactsUseCase
    @Dependency(\.deleteContactUseCase) var deleteContactUseCase
    @Dependency(\.currentUser) var currentUser
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let user = try await currentUser()
                    let contacts = try await fetchContactsUseCase.execute(userId: user.id)
                    await send(.contactsResponse(.success(contacts)))
                } catch: { error, send in
                    await send(.contactsResponse(.failure(error)))
                }
                
            case let .contactsResponse(.success(contacts)):
                state.isLoading = false
                state.contacts = contacts
                state.contactLimit = ContactLimit(
                    currentCount: contacts.count,
                    isPremium: false // TODO: 실제 구독 상태 반영
                )
                return .none
                
            case let .contactsResponse(.failure(error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none
                
            case let .deleteContactTapped(contact):
                guard contact.isDeletable else {
                    state.error = "아직 삭제할 수 없습니다. \(contact.remainingLockDays)일 후 삭제 가능합니다."
                    return .none
                }
                
                return .run { send in
                    try await deleteContactUseCase.execute(contactId: contact.id)
                    await send(.deleteContactResponse(.success(())))
                } catch: { error, send in
                    await send(.deleteContactResponse(.failure(error)))
                }
                
            case .deleteContactResponse(.success):
                // 목록 새로고침
                return .send(.onAppear)
                
            case let .deleteContactResponse(.failure(error)):
                state.error = error.localizedDescription
                return .none
                
            case .addContactTapped:
                state.destination = .addContact(ContactFormFeature.State())
                return .none
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ContactListFeature {
    @Reducer
    enum Destination {
        case addContact(ContactFormFeature)
        case contactDetail(ContactDetailFeature)
    }
}
```

**ContactListView.swift**
```swift
import SwiftUI
import ComposableArchitecture

struct ContactListView: View {
    @Bindable var store: StoreOf<ContactListFeature>
    
    var body: some View {
        NavigationStack {
            Group {
                if store.isLoading {
                    ProgressView()
                } else if store.contacts.isEmpty {
                    emptyView
                } else {
                    contactList
                }
            }
            .navigationTitle("연락처")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .alert(
                "오류",
                isPresented: Binding(
                    get: { store.error != nil },
                    set: { if !$0 { store.error = nil } }
                )
            ) {
                Button("확인", role: .cancel) { }
            } message: {
                if let error = store.error {
                    Text(error)
                }
            }
            .sheet(
                item: $store.scope(state: \.destination?.addContact, action: \.destination.addContact)
            ) { store in
                ContactFormView(store: store)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    private var contactList: some View {
        List {
            Section {
                if let limit = store.contactLimit {
                    contactLimitInfo(limit)
                }
            }
            
            Section {
                ForEach(store.contacts) { contact in
                    ContactRow(
                        contact: contact,
                        onDelete: { store.send(.deleteContactTapped(contact)) }
                    )
                }
            }
        }
    }
    
    private func contactLimitInfo(_ limit: ContactLimit) -> some View {
        HStack {
            Text("등록된 연락처")
            Spacer()
            Text("\(limit.currentCount) / \(limit.maxContacts)")
                .foregroundColor(.secondary)
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("등록된 연락처가 없습니다")
                .font(.headline)
            Text("연락처를 추가하여 쪽지를 보내보세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var addButton: some View {
        Button {
            store.send(.addContactTapped)
        } label: {
            Image(systemName: "plus")
        }
        .disabled(!(store.contactLimit?.canAddContact ?? false))
    }
}

struct ContactRow: View {
    let contact: Contact
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.headline)
                
                if let relationship = contact.relationship {
                    Text(relationship)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if !contact.isDeletable {
                    Text("\(contact.remainingLockDays)일 후 삭제 가능")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(contact.isDeletable ? .red : .gray)
            }
            .disabled(!contact.isDeletable)
        }
        .padding(.vertical, 4)
    }
}
```

---

## 4. Dependency Injection (TCA Dependencies)

### 4.1 DependencyKey 정의

**DependencyKey.swift**
```swift
import ComposableArchitecture
import Foundation

// Use Case Dependencies
extension DependencyValues {
    var fetchContactsUseCase: FetchContactsUseCase {
        get { self[FetchContactsUseCaseKey.self] }
        set { self[FetchContactsUseCaseKey.self] = newValue }
    }
    
    var addContactUseCase: AddContactUseCase {
        get { self[AddContactUseCaseKey.self] }
        set { self[AddContactUseCaseKey.self] = newValue }
    }
    
    var deleteContactUseCase: DeleteContactUseCase {
        get { self[DeleteContactUseCaseKey.self] }
        set { self[DeleteContactUseCaseKey.self] = newValue }
    }
    
    var sendMessageUseCase: SendMessageUseCase {
        get { self[SendMessageUseCaseKey.self] }
        set { self[SendMessageUseCaseKey.self] = newValue }
    }
    
    var currentUser: @Sendable () async throws -> User {
        get { self[CurrentUserKey.self] }
        set { self[CurrentUserKey.self] = newValue }
    }
}

// Repository Dependencies
extension DependencyValues {
    var contactRepository: ContactRepositoryInterface {
        get { self[ContactRepositoryKey.self] }
        set { self[ContactRepositoryKey.self] = newValue }
    }
    
    var messageRepository: MessageRepositoryInterface {
        get { self[MessageRepositoryKey.self] }
        set { self[MessageRepositoryKey.self] = newValue }
    }
    
    var userRepository: UserRepositoryInterface {
        get { self[UserRepositoryKey.self] }
        set { self[UserRepositoryKey.self] = newValue }
    }
    
    var authRepository: AuthRepositoryInterface {
        get { self[AuthRepositoryKey.self] }
        set { self[AuthRepositoryKey.self] = newValue }
    }
}

// Keys
private enum FetchContactsUseCaseKey: DependencyKey {
    static let liveValue = FetchContactsUseCase(
        contactRepository: ContactRepository(
            remoteDataSource: ContactAPIService(),
            localDataSource: ContactLocalDataSource()
        )
    )
    
    static let testValue = FetchContactsUseCase(
        contactRepository: MockContactRepository()
    )
}

private enum AddContactUseCaseKey: DependencyKey {
    static let liveValue = AddContactUseCase(
        contactRepository: ContactRepository(
            remoteDataSource: ContactAPIService(),
            localDataSource: ContactLocalDataSource()
        )
    )
    
    static let testValue = AddContactUseCase(
        contactRepository: MockContactRepository()
    )
}

private enum DeleteContactUseCaseKey: DependencyKey {
    static let liveValue = DeleteContactUseCase(
        contactRepository: ContactRepository(
            remoteDataSource: ContactAPIService(),
            localDataSource: ContactLocalDataSource()
        )
    )
    
    static let testValue = DeleteContactUseCase(
        contactRepository: MockContactRepository()
    )
}

private enum SendMessageUseCaseKey: DependencyKey {
    static let liveValue = SendMessageUseCase(
        messageRepository: MessageRepository(
            remoteDataSource: MessageAPIService(),
            localDataSource: MessageLocalDataSource()
        ),
        contactRepository: ContactRepository(
            remoteDataSource: ContactAPIService(),
            localDataSource: ContactLocalDataSource()
        )
    )
    
    static let testValue = SendMessageUseCase(
        messageRepository: MockMessageRepository(),
        contactRepository: MockContactRepository()
    )
}

private enum CurrentUserKey: DependencyKey {
    static let liveValue: @Sendable () async throws -> User = {
        let repository = AuthRepository(
            remoteDataSource: AuthAPIService(),
            localDataSource: AuthLocalDataSource()
        )
        return try await repository.getCurrentUser() ?? {
            throw AuthError.notAuthenticated
        }()
    }
    
    static let testValue: @Sendable () async throws -> User = {
        User(
            id: UUID(),
            username: "testuser",
            email: "test@example.com",
            profileImageURL: nil,
            personalLink: PersonalLink(userId: UUID(), token: "test-token"),
            createdAt: Date()
        )
    }
}

private enum ContactRepositoryKey: DependencyKey {
    static let liveValue: ContactRepositoryInterface = ContactRepository(
        remoteDataSource: ContactAPIService(),
        localDataSource: ContactLocalDataSource()
    )
    
    static let testValue: ContactRepositoryInterface = MockContactRepository()
}

private enum MessageRepositoryKey: DependencyKey {
    static let liveValue: MessageRepositoryInterface = MessageRepository(
        remoteDataSource: MessageAPIService(),
        localDataSource: MessageLocalDataSource()
    )
    
    static let testValue: MessageRepositoryInterface = MockMessageRepository()
}

private enum UserRepositoryKey: DependencyKey {
    static let liveValue: UserRepositoryInterface = UserRepository(
        remoteDataSource: UserAPIService(),
        localDataSource: UserLocalDataSource()
    )
    
    static let testValue: UserRepositoryInterface = MockUserRepository()
}

private enum AuthRepositoryKey: DependencyKey {
    static let liveValue: AuthRepositoryInterface = AuthRepository(
        remoteDataSource: AuthAPIService(),
        localDataSource: AuthLocalDataSource()
    )
    
    static let testValue: AuthRepositoryInterface = MockAuthRepository()
}
```

---

## 5. 데이터 흐름 예시

### 5.1 연락처 추가 플로우

```
User Interaction (View)
    ↓
Action (.addContactTapped)
    ↓
Reducer (Feature)
    ↓
Effect (UseCase 호출)
    ↓
AddContactUseCase.execute()
    ├─ Validation (비즈니스 로직)
    └─ ContactRepository.addContact()
        ├─ Remote API 호출
        ├─ DTO → Entity 변환
        └─ Local DB 저장
    ↓
Result (Success/Failure)
    ↓
Action (.contactAddResponse)
    ↓
State Update
    ↓
View Re-render
```

### 5.2 쪽지 발송 플로우

```
MessageComposeView
    ↓
.send(.sendMessageTapped)
    ↓
MessageComposeFeature.Reducer
    ↓
Effect {
    SendMessageUseCase.execute(
        senderId: currentUser.id,
        contactId: contact.id,
        content: state.content,
        isAnonymous: state.isAnonymous
    )
}
    ↓
SendMessageUseCase
    ├─ ContactRepository.fetchContact() // 유효성 검증
    └─ MessageRepository.sendMessage()
        ├─ API 호출
        ├─ 로컬 캐싱
        └─ Result 반환
    ↓
.messageSentResponse(.success(message))
    ↓
State.sentMessage = message
State.showSuccess = true
    ↓
View 업데이트
```

---

## 6. 테스트 전략

### 6.1 Domain Layer 테스트

**Use Case 테스트 예시**
```swift
import XCTest
@testable import AnonymousMessageApp

final class AddContactUseCaseTests: XCTestCase {
    var sut: AddContactUseCase!
    var mockRepository: MockContactRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockContactRepository()
        sut = AddContactUseCase(contactRepository: mockRepository)
    }
    
    func testAddContact_Success() async throws {
        // Given
        let userId = UUID()
        mockRepository.contactsToReturn = []
        
        // When
        let contact = try await sut.execute(
            ownerUserId: userId,
            name: "홍길동",
            relationship: "친구",
            memo: nil,
            isPremium: false
        )
        
        // Then
        XCTAssertEqual(contact.name, "홍길동")
        XCTAssertEqual(contact.relationship, "친구")
        XCTAssertTrue(mockRepository.addContactCalled)
    }
    
    func testAddContact_LimitReached_ThrowsError() async {
        // Given
        let userId = UUID()
        mockRepository.contactsToReturn = Array(repeating: Contact.mock(), count: 5)
        
        // When & Then
        do {
            _ = try await sut.execute(
                ownerUserId: userId,
                name: "홍길동",
                relationship: nil,
                memo: nil,
                isPremium: false
            )
            XCTFail("Should throw ContactError.limitReached")
        } catch let error as ContactError {
            XCTAssertEqual(error, .limitReached)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
```

### 6.2 Presentation Layer 테스트

**Feature 테스트 예시**
```swift
import XCTest
import ComposableArchitecture
@testable import AnonymousMessageApp

@MainActor
final class ContactListFeatureTests: XCTestCase {
    func testOnAppear_LoadsContacts() async {
        // Given
        let contacts = [Contact.mock(), Contact.mock()]
        let store = TestStore(initialState: ContactListFeature.State()) {
            ContactListFeature()
        } withDependencies: {
            $0.fetchContactsUseCase = FetchContactsUseCase(
                contactRepository: MockContactRepository(contactsToReturn: contacts)
            )
            $0.currentUser = { User.mock() }
        }
        
        // When
        await store.send(.onAppear) {
            $0.isLoading = true
        }
        
        // Then
        await store.receive(\.contactsResponse.success) {
            $0.isLoading = false
            $0.contacts = contacts
            $0.contactLimit = ContactLimit(currentCount: 2, isPremium: false)
        }
    }
    
    func testDeleteContact_WhenDeletable_Success() async {
        // Given
        let contact = Contact.mock(registeredAt: Date().addingTimeInterval(-4 * 24 * 60 * 60))
        let store = TestStore(
            initialState: ContactListFeature.State(contacts: [contact])
        ) {
            ContactListFeature()
        } withDependencies: {
            $0.deleteContactUseCase = DeleteContactUseCase(
                contactRepository: MockContactRepository()
            )
        }
        
        // When
        await store.send(.deleteContactTapped(contact))
        
        // Then
        await store.receive(\.deleteContactResponse.success)
        await store.receive(.onAppear)
    }
}
```

---

## 7. 핵심 설계 원칙 요약

### 7.1 SOLID 원칙 적용

1. **Single Responsibility**: 각 클래스는 하나의 책임만
   - Use Case는 하나의 비즈니스 로직만
   - Repository는 데이터 접근만
   - Feature는 하나의 화면 로직만

2. **Open/Closed**: 확장에 열려있고 수정에 닫혀있음
   - Protocol을 통한 추상화
   - 새로운 구현체 추가 가능

3. **Liskov Substitution**: Protocol 구현체는 교체 가능
   - Mock/Real 구현체 자유롭게 교체

4. **Interface Segregation**: 필요한 인터페이스만 의존
   - Repository Interface를 작게 분리

5. **Dependency Inversion**: 상위 모듈이 하위 모듈에 의존하지 않음
   - Domain이 Data에 의존하지 않음
   - Protocol을 통한 역전

### 7.2 TCA 설계 원칙

1. **단방향 데이터 흐름**: View → Action → State → View
2. **Pure Functions**: Reducer는 순수 함수
3. **Side Effect 분리**: Effect를 통한 비동기 처리
4. **Testability**: 모든 로직이 테스트 가능
5. **Composition**: Feature 조합을 통한 화면 구성

### 7.3 Clean Architecture 핵심

1. **계층 분리**: Presentation, Domain, Data 명확히 분리
2. **의존성 규칙**: 항상 외부에서 내부로
3. **추상화**: Protocol을 통한 느슨한 결합
4. **독립성**: 각 레이어가 독립적으로 테스트 가능

---

## 8. 다음 단계

1. ✅ PRD 작성 완료
2. ✅ 아키텍처 설계 완료
3. ⏭️ 구현 시작
   - Domain Layer 구현
   - Data Layer 구현
   - Presentation Layer 구현
4. 테스트 작성
5. UI/UX 구현

---

**문서 버전**: 1.0  
**작성일**: 2025-12-05  
**최종 수정일**: 2025-12-05
