//
//  FetchMessageHistoryUseCase.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 쪽지 히스토리 조회 Use Case
/// 쪽지 히스토리 조회 비즈니스 로직을 담당
struct FetchMessageHistoryUseCase {
    // MARK: - Dependencies
    
    private let messageRepository: MessageRepositoryInterface
    
    // MARK: - Initialization
    
    init(messageRepository: MessageRepositoryInterface) {
        self.messageRepository = messageRepository
    }
    
    // MARK: - Execution
    
    /// 히스토리 조회 실행
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - type: 히스토리 타입
    /// - Returns: 쪽지 목록
    /// - Throws: 조회 실패 시 에러
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
        return sortMessages(messages)
    }
    
    /// 답변 완료된 쪽지만 조회
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - type: 히스토리 타입
    /// - Returns: 답변 완료된 쪽지 목록
    /// - Throws: 조회 실패 시 에러
    func fetchAnsweredMessages(userId: UUID, type: HistoryType) async throws -> [Message] {
        let messages = try await execute(userId: userId, type: type)
        return messages.filter { $0.isAnswered }
    }
    
    /// 답변 대기 중인 쪽지만 조회
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - type: 히스토리 타입
    /// - Returns: 답변 대기 중인 쪽지 목록
    /// - Throws: 조회 실패 시 에러
    func fetchPendingMessages(userId: UUID, type: HistoryType) async throws -> [Message] {
        let messages = try await execute(userId: userId, type: type)
        return messages.filter { !$0.isAnswered }
    }
    
    /// 특정 기간의 쪽지 조회
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - type: 히스토리 타입
    ///   - startDate: 시작 날짜
    ///   - endDate: 종료 날짜
    /// - Returns: 해당 기간의 쪽지 목록
    /// - Throws: 조회 실패 시 에러
    func fetchMessages(
        userId: UUID,
        type: HistoryType,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [Message] {
        let messages = try await execute(userId: userId, type: type)
        return messages.filter { message in
            message.sentAt >= startDate && message.sentAt <= endDate
        }
    }
    
    // MARK: - Private Methods
    
    /// 쪽지 정렬
    /// - Parameter messages: 정렬할 쪽지 목록
    /// - Returns: 정렬된 쪽지 목록
    /// - Note: 전송일시 최신순으로 정렬
    private func sortMessages(_ messages: [Message]) -> [Message] {
        messages.sorted { $0.sentAt > $1.sentAt }
    }
}

// MARK: - History Type

/// 히스토리 타입
enum HistoryType: Equatable {
    /// 보낸 쪽지
    case sent
    
    /// 받은 쪽지
    case received
    
    /// 특정 연락처와 주고받은 쪽지
    case forContact(UUID)
    
    var displayName: String {
        switch self {
        case .sent:
            return "보낸 쪽지"
        case .received:
            return "받은 쪽지"
        case .forContact:
            return "대화 내역"
        }
    }
}
