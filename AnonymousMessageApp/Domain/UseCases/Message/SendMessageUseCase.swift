//
//  SendMessageUseCase.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 쪽지 전송 Use Case
/// 쪽지 전송 비즈니스 로직을 담당
struct SendMessageUseCase {
    // MARK: - Dependencies
    
    private let messageRepository: MessageRepositoryInterface
    private let contactRepository: ContactRepositoryInterface
    
    // MARK: - Initialization
    
    init(
        messageRepository: MessageRepositoryInterface,
        contactRepository: ContactRepositoryInterface
    ) {
        self.messageRepository = messageRepository
        self.contactRepository = contactRepository
    }
    
    // MARK: - Execution
    
    /// 쪽지 전송 실행
    /// - Parameters:
    ///   - senderId: 발신자 ID
    ///   - contactId: 연락처 ID
    ///   - content: 쪽지 내용
    ///   - isAnonymous: 익명 전송 여부
    /// - Returns: 전송된 쪽지
    /// - Throws: 유효성 검증 실패 또는 전송 실패 시 에러
    func execute(
        senderId: UUID,
        contactId: UUID,
        content: String,
        isAnonymous: Bool
    ) async throws -> Message {
        // 1. 내용 유효성 검증
        try validateContent(content)
        
        // 2. 연락처 유효성 검증
        let contact = try await contactRepository.fetchContact(byId: contactId)
        
        // 3. 연락처 소유자 검증
        guard contact.ownerUserId == senderId else {
            throw SendMessageError.unauthorizedContact
        }
        
        // 4. 수신자가 자기 자신이 아닌지 확인
        // Note: receiverId는 실제로는 contact의 등록 대상이므로 별도 처리 필요
        // 현재는 contactId만 사용하므로 생략
        
        // 5. 쪽지 생성
        let message = Message(
            id: UUID(),
            senderId: senderId,
            receiverId: contact.ownerUserId, // TODO: 실제 수신자 ID로 변경 필요
            contactId: contactId,
            content: content,
            isAnonymous: isAnonymous,
            sentAt: Date(),
            answer: nil
        )
        
        // 6. 쪽지 전송
        return try await messageRepository.sendMessage(message)
    }
    
    // MARK: - Private Methods
    
    private func validateContent(_ content: String) throws {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedContent.isEmpty else {
            throw SendMessageError.emptyContent
        }
        
        guard trimmedContent.count >= 10 else {
            throw SendMessageError.contentTooShort
        }
        
        guard trimmedContent.count <= 1000 else {
            throw SendMessageError.contentTooLong
        }
    }
}

// MARK: - Errors

enum SendMessageError: Error, LocalizedError {
    case emptyContent
    case contentTooShort
    case contentTooLong
    case unauthorizedContact
    case contactNotFound
    case sendToSelf
    case sendFailed
    
    var errorDescription: String? {
        switch self {
        case .emptyContent:
            return "쪽지 내용을 입력해주세요."
        case .contentTooShort:
            return "쪽지 내용은 최소 10자 이상 입력해주세요."
        case .contentTooLong:
            return "쪽지 내용은 최대 1000자까지 입력할 수 있습니다."
        case .unauthorizedContact:
            return "본인이 등록한 연락처에만 쪽지를 보낼 수 있습니다."
        case .contactNotFound:
            return "연락처를 찾을 수 없습니다."
        case .sendToSelf:
            return "자기 자신에게는 쪽지를 보낼 수 없습니다."
        case .sendFailed:
            return "쪽지 전송에 실패했습니다."
        }
    }
}
