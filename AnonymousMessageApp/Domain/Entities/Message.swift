//
//  Message.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 쪽지 엔티티
/// 사용자 간 주고받는 메시지를 나타내는 도메인 모델
struct Message: Equatable, Identifiable {
    /// 쪽지 고유 ID
    let id: UUID
    
    /// 발신자 ID
    let senderId: UUID
    
    /// 수신자 ID
    let receiverId: UUID
    
    /// 발신자의 연락처 ID (발신자가 등록한 수신자 정보)
    let contactId: UUID?
    
    /// 쪽지 내용
    let content: String
    
    /// 익명 전송 여부
    let isAnonymous: Bool
    
    /// 전송일시
    let sentAt: Date
    
    /// 답변 (있을 경우)
    var answer: Answer?
    
    /// 쪽지 상태
    var status: MessageStatus {
        answer == nil ? .pending : .answered
    }
    
    /// 발신자 표시 이름 (익명인 경우 "익명")
    var displaySenderName: String {
        isAnonymous ? "익명" : "알 수 없음"
    }
    
    /// 답변 완료 여부
    var isAnswered: Bool {
        answer != nil
    }
    
    /// 쪽지 내용이 비어있는지 여부
    var isEmpty: Bool {
        content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Mock Data (테스트용)
#if DEBUG
extension Message {
    static func mock(
        id: UUID = UUID(),
        senderId: UUID = UUID(),
        receiverId: UUID = UUID(),
        contactId: UUID? = UUID(),
        content: String = "안녕하세요. 궁금한 게 있어서 쪽지 남깁니다.",
        isAnonymous: Bool = true,
        sentAt: Date = Date(),
        answer: Answer? = nil
    ) -> Message {
        Message(
            id: id,
            senderId: senderId,
            receiverId: receiverId,
            contactId: contactId,
            content: content,
            isAnonymous: isAnonymous,
            sentAt: sentAt,
            answer: answer
        )
    }
    
    /// 답변이 있는 쪽지 Mock
    static func answeredMock(
        id: UUID = UUID(),
        senderId: UUID = UUID(),
        receiverId: UUID = UUID(),
        content: String = "질문 내용입니다.",
        answerContent: String = "답변 내용입니다."
    ) -> Message {
        let messageId = id
        let answer = Answer(
            id: UUID(),
            messageId: messageId,
            content: answerContent,
            answeredAt: Date()
        )
        
        return Message(
            id: messageId,
            senderId: senderId,
            receiverId: receiverId,
            contactId: UUID(),
            content: content,
            isAnonymous: true,
            sentAt: Date().addingTimeInterval(-3600), // 1시간 전
            answer: answer
        )
    }
    
    /// 답변 대기 중인 쪽지 Mock
    static func pendingMock(
        id: UUID = UUID(),
        senderId: UUID = UUID(),
        receiverId: UUID = UUID(),
        content: String = "질문이 있어요!"
    ) -> Message {
        Message(
            id: id,
            senderId: senderId,
            receiverId: receiverId,
            contactId: UUID(),
            content: content,
            isAnonymous: true,
            sentAt: Date(),
            answer: nil
        )
    }
}
#endif
