//
//  Answer.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 답변 엔티티
/// 쪽지에 대한 답변을 나타내는 도메인 모델
struct Answer: Equatable, Identifiable {
    /// 답변 고유 ID
    let id: UUID
    
    /// 답변 대상 쪽지 ID
    let messageId: UUID
    
    /// 답변 내용
    let content: String
    
    /// 답변 작성일시
    let answeredAt: Date
    
    /// 답변 내용이 비어있는지 여부
    var isEmpty: Bool {
        content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Mock Data (테스트용)
#if DEBUG
extension Answer {
    static func mock(
        id: UUID = UUID(),
        messageId: UUID = UUID(),
        content: String = "답변 내용입니다.",
        answeredAt: Date = Date()
    ) -> Answer {
        Answer(
            id: id,
            messageId: messageId,
            content: content,
            answeredAt: answeredAt
        )
    }
}
#endif
