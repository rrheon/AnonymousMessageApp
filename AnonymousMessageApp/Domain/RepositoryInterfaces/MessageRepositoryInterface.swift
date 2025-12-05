//
//  MessageRepositoryInterface.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 쪽지 Repository 인터페이스
/// 쪽지 데이터 접근을 위한 프로토콜
protocol MessageRepositoryInterface {
    /// 쪽지 전송
    /// - Parameter message: 전송할 쪽지
    /// - Returns: 전송된 쪽지
    /// - Throws: 전송 실패 시 에러
    func sendMessage(_ message: Message) async throws -> Message
    
    /// 사용자가 보낸 쪽지 목록 조회
    /// - Parameter userId: 사용자 ID
    /// - Returns: 보낸 쪽지 목록
    /// - Throws: 조회 실패 시 에러
    func fetchSentMessages(forUserId userId: UUID) async throws -> [Message]
    
    /// 사용자가 받은 쪽지 목록 조회
    /// - Parameter userId: 사용자 ID
    /// - Returns: 받은 쪽지 목록
    /// - Throws: 조회 실패 시 에러
    func fetchReceivedMessages(forUserId userId: UUID) async throws -> [Message]
    
    /// ID로 쪽지 조회
    /// - Parameter id: 쪽지 ID
    /// - Returns: 조회된 쪽지
    /// - Throws: 쪽지를 찾을 수 없는 경우 에러
    func fetchMessage(byId id: UUID) async throws -> Message
    
    /// 특정 연락처와 주고받은 쪽지 목록 조회
    /// - Parameter contactId: 연락처 ID
    /// - Returns: 주고받은 쪽지 목록
    /// - Throws: 조회 실패 시 에러
    func fetchMessagesForContact(contactId: UUID) async throws -> [Message]
    
    /// 쪽지에 답변 추가
    /// - Parameters:
    ///   - messageId: 쪽지 ID
    ///   - answer: 답변
    /// - Returns: 업데이트된 쪽지
    /// - Throws: 답변 추가 실패 시 에러
    func answerMessage(messageId: UUID, answer: Answer) async throws -> Message
}
