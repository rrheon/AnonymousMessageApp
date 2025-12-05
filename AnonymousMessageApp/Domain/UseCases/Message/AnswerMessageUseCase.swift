//
//  AnswerMessageUseCase.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 쪽지 답변 Use Case
/// 쪽지 답변 비즈니스 로직을 담당
struct AnswerMessageUseCase {
    // MARK: - Dependencies
    
    private let messageRepository: MessageRepositoryInterface
    
    // MARK: - Initialization
    
    init(messageRepository: MessageRepositoryInterface) {
        self.messageRepository = messageRepository
    }
    
    // MARK: - Execution
    
    /// 쪽지 답변 실행
    /// - Parameters:
    ///   - messageId: 답변할 쪽지 ID
    ///   - content: 답변 내용
    ///   - answererId: 답변자 ID
    /// - Returns: 답변이 추가된 쪽지
    /// - Throws: 유효성 검증 실패 또는 답변 추가 실패 시 에러
    func execute(
        messageId: UUID,
        content: String,
        answererId: UUID
    ) async throws -> Message {
        // 1. 답변 내용 유효성 검증
        try validateContent(content)
        
        // 2. 쪽지 조회
        let message = try await messageRepository.fetchMessage(byId: messageId)
        
        // 3. 수신자 검증 (답변자가 쪽지 수신자인지 확인)
        guard message.receiverId == answererId else {
            throw AnswerMessageError.unauthorized
        }
        
        // 4. 이미 답변했는지 확인
        guard message.answer == nil else {
            throw AnswerMessageError.alreadyAnswered
        }
        
        // 5. 답변 생성
        let answer = Answer(
            id: UUID(),
            messageId: messageId,
            content: content,
            answeredAt: Date()
        )
        
        // 6. 답변 추가
        return try await messageRepository.answerMessage(messageId: messageId, answer: answer)
    }
    
    // MARK: - Private Methods
    
    private func validateContent(_ content: String) throws {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedContent.isEmpty else {
            throw AnswerMessageError.emptyContent
        }
        
        guard trimmedContent.count >= 5 else {
            throw AnswerMessageError.contentTooShort
        }
        
        guard trimmedContent.count <= 1000 else {
            throw AnswerMessageError.contentTooLong
        }
    }
}

// MARK: - Errors

enum AnswerMessageError: Error, LocalizedError {
    case emptyContent
    case contentTooShort
    case contentTooLong
    case unauthorized
    case alreadyAnswered
    case messageNotFound
    case answerFailed
    
    var errorDescription: String? {
        switch self {
        case .emptyContent:
            return "답변 내용을 입력해주세요."
        case .contentTooShort:
            return "답변 내용은 최소 5자 이상 입력해주세요."
        case .contentTooLong:
            return "답변 내용은 최대 1000자까지 입력할 수 있습니다."
        case .unauthorized:
            return "본인이 받은 쪽지에만 답변할 수 있습니다."
        case .alreadyAnswered:
            return "이미 답변한 쪽지입니다."
        case .messageNotFound:
            return "쪽지를 찾을 수 없습니다."
        case .answerFailed:
            return "답변 추가에 실패했습니다."
        }
    }
}
