//
//  ContactLimit.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 연락처 제한 Value Object
/// 연락처 등록 및 삭제 제한 규칙을 관리
struct ContactLimit {
    // MARK: - Constants
    
    /// 무료 사용자의 최대 연락처 수
    static let maxFreeContacts = 5
    
    /// 삭제 잠금 기간 (3일)
    static let deletionLockPeriod: TimeInterval = 3 * 24 * 60 * 60
    
    // MARK: - Properties
    
    /// 현재 등록된 연락처 수
    let currentCount: Int
    
    /// 프리미엄 구독 여부
    let isPremium: Bool
    
    // MARK: - Computed Properties
    
    /// 최대 연락처 수
    var maxContacts: Int {
        isPremium ? .max : Self.maxFreeContacts
    }
    
    /// 연락처 추가 가능 여부
    var canAddContact: Bool {
        currentCount < maxContacts
    }
    
    /// 남은 슬롯 수
    var remainingSlots: Int {
        max(0, maxContacts - currentCount)
    }
    
    /// 제한 도달 여부
    var isLimitReached: Bool {
        !canAddContact
    }
    
    /// 상태 메시지
    var statusMessage: String {
        if isPremium {
            return "프리미엄: 무제한"
        } else {
            return "\(currentCount) / \(maxContacts)"
        }
    }
    
    /// 제한 안내 메시지
    var limitMessage: String? {
        guard isLimitReached else { return nil }
        return "무료 버전은 최대 \(Self.maxFreeContacts)명까지 등록할 수 있습니다."
    }
    
    // MARK: - Methods
    
    /// 연락처 삭제 가능 여부 확인
    func canDeleteContact(_ contact: Contact) -> Bool {
        contact.isDeletable
    }
    
    /// 연락처 삭제 불가 사유
    func deletionBlockReason(for contact: Contact) -> String? {
        guard !contact.isDeletable else { return nil }
        return "등록 후 3일이 지나야 삭제할 수 있습니다. (\(contact.remainingLockDays)일 남음)"
    }
    
    /// 프리미엄 업그레이드 필요 여부
    var needsUpgrade: Bool {
        !isPremium && isLimitReached
    }
}

// MARK: - Validation
extension ContactLimit {
    enum ValidationError: Error, LocalizedError {
        case limitReached
        case deletionLocked(remainingDays: Int)
        
        var errorDescription: String? {
            switch self {
            case .limitReached:
                return "연락처 등록 한도에 도달했습니다."
            case .deletionLocked(let days):
                return "등록 후 3일이 지나야 삭제할 수 있습니다. (\(days)일 남음)"
            }
        }
    }
    
    /// 연락처 추가 가능 여부 검증
    func validateAddContact() throws {
        guard canAddContact else {
            throw ValidationError.limitReached
        }
    }
    
    /// 연락처 삭제 가능 여부 검증
    func validateDeleteContact(_ contact: Contact) throws {
        guard contact.isDeletable else {
            throw ValidationError.deletionLocked(remainingDays: contact.remainingLockDays)
        }
    }
}

// MARK: - Mock Data (테스트용)
#if DEBUG
extension ContactLimit {
    static func mock(
        currentCount: Int = 0,
        isPremium: Bool = false
    ) -> ContactLimit {
        ContactLimit(
            currentCount: currentCount,
            isPremium: isPremium
        )
    }
    
    /// 제한에 도달한 상태 Mock
    static func limitReachedMock() -> ContactLimit {
        ContactLimit(
            currentCount: maxFreeContacts,
            isPremium: false
        )
    }
    
    /// 프리미엄 사용자 Mock
    static func premiumMock(currentCount: Int = 10) -> ContactLimit {
        ContactLimit(
            currentCount: currentCount,
            isPremium: true
        )
    }
}
#endif
