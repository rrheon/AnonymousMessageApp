//
//  MessageStatus.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 쪽지 상태
enum MessageStatus: String, Equatable, Codable {
    /// 답변 대기 중
    case pending = "pending"
    
    /// 답변 완료
    case answered = "answered"
    
    /// 표시용 텍스트
    var displayText: String {
        switch self {
        case .pending:
            return "답변 대기"
        case .answered:
            return "답변 완료"
        }
    }
    
    /// 아이콘 이름 (SF Symbols)
    var iconName: String {
        switch self {
        case .pending:
            return "clock"
        case .answered:
            return "checkmark.circle.fill"
        }
    }
}
