//
//  DeleteContactUseCase.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 연락처 삭제 Use Case
/// 연락처 삭제 비즈니스 로직을 담당
struct DeleteContactUseCase {
    // MARK: - Dependencies
    
    private let contactRepository: ContactRepositoryInterface
    
    // MARK: - Initialization
    
    init(contactRepository: ContactRepositoryInterface) {
        self.contactRepository = contactRepository
    }
    
    // MARK: - Execution
    
    /// 연락처 삭제 실행
    /// - Parameter contactId: 삭제할 연락처 ID
    /// - Throws: 삭제 불가능하거나 실패 시 에러
    func execute(contactId: UUID) async throws {
        // 1. 연락처 조회
        let contact = try await contactRepository.fetchContact(byId: contactId)
        
        // 2. 삭제 가능 여부 검증
        guard contact.isDeletable else {
            throw DeleteContactError.contactLocked(
                remainingDays: contact.remainingLockDays,
                deletableDate: contact.deletableAt
            )
        }
        
        // 3. 삭제 실행
        try await contactRepository.deleteContact(byId: contactId)
    }
    
    /// 강제 삭제 (관리자용)
    /// - Parameter contactId: 삭제할 연락처 ID
    /// - Throws: 삭제 실패 시 에러
    /// - Note: 삭제 잠금 기간을 무시하고 삭제
    func forceDelete(contactId: UUID) async throws {
        try await contactRepository.deleteContact(byId: contactId)
    }
}

// MARK: - Errors

enum DeleteContactError: Error, LocalizedError {
    case contactLocked(remainingDays: Int, deletableDate: Date)
    case contactNotFound
    case deleteFailed
    
    var errorDescription: String? {
        switch self {
        case .contactLocked(let remainingDays, let deletableDate):
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let dateString = dateFormatter.string(from: deletableDate)
            return "등록 후 3일이 지나야 삭제할 수 있습니다.\n\(dateString)부터 삭제 가능합니다. (\(remainingDays)일 남음)"
        case .contactNotFound:
            return "연락처를 찾을 수 없습니다."
        case .deleteFailed:
            return "연락처 삭제에 실패했습니다."
        }
    }
}
