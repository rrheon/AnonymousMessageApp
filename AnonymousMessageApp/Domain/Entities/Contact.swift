//
//  Contact.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 연락처 엔티티
/// 사용자가 쪽지를 보낼 대상을 관리하는 도메인 모델
struct Contact: Equatable, Identifiable {
    /// 연락처 고유 ID
    let id: UUID
    
    /// 연락처를 소유한 사용자 ID
    let ownerUserId: UUID
    
    /// 연락처 이름
    let name: String
    
    /// 관계 (예: 친구, 가족, 동료 등)
    let relationship: String?
    
    /// 메모
    let memo: String?
    
    /// 등록일
    let registeredAt: Date
    
    /// 삭제 가능 시점 (등록일 + 3일)
    var deletableAt: Date {
        registeredAt.addingTimeInterval(ContactLimit.deletionLockPeriod)
    }
    
    /// 삭제 가능 여부
    var isDeletable: Bool {
        Date() >= deletableAt
    }
    
    /// 삭제까지 남은 일수
    var remainingLockDays: Int {
        let remaining = deletableAt.timeIntervalSince(Date())
        return max(0, Int(ceil(remaining / (24 * 60 * 60))))
    }
    
    /// 삭제 잠금 상태 메시지
    var lockStatusMessage: String? {
        guard !isDeletable else { return nil }
        return "\(remainingLockDays)일 후 삭제 가능"
    }
}

// MARK: - Mock Data (테스트용)
#if DEBUG
extension Contact {
    static func mock(
        id: UUID = UUID(),
        ownerUserId: UUID = UUID(),
        name: String = "홍길동",
        relationship: String? = "친구",
        memo: String? = nil,
        registeredAt: Date = Date()
    ) -> Contact {
        Contact(
            id: id,
            ownerUserId: ownerUserId,
            name: name,
            relationship: relationship,
            memo: memo,
            registeredAt: registeredAt
        )
    }
    
    /// 삭제 가능한 연락처 Mock
    static func deletableMock(
        id: UUID = UUID(),
        ownerUserId: UUID = UUID(),
        name: String = "홍길동"
    ) -> Contact {
        Contact(
            id: id,
            ownerUserId: ownerUserId,
            name: name,
            relationship: "친구",
            memo: nil,
            registeredAt: Date().addingTimeInterval(-4 * 24 * 60 * 60) // 4일 전
        )
    }
    
    /// 삭제 불가능한 연락처 Mock
    static func lockedMock(
        id: UUID = UUID(),
        ownerUserId: UUID = UUID(),
        name: String = "김철수"
    ) -> Contact {
        Contact(
            id: id,
            ownerUserId: ownerUserId,
            name: name,
            relationship: "동료",
            memo: nil,
            registeredAt: Date().addingTimeInterval(-1 * 24 * 60 * 60) // 1일 전
        )
    }
}
#endif
