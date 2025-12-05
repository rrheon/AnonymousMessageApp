//
//  AddContactUseCase.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 연락처 추가 Use Case
/// 연락처 추가 비즈니스 로직을 담당
struct AddContactUseCase {
    // MARK: - Dependencies
    
    private let contactRepository: ContactRepositoryInterface
    
    // MARK: - Initialization
    
    init(contactRepository: ContactRepositoryInterface) {
        self.contactRepository = contactRepository
    }
    
    // MARK: - Execution
    
    /// 연락처 추가 실행
    /// - Parameters:
    ///   - ownerUserId: 연락처를 등록하는 사용자 ID
    ///   - name: 연락처 이름
    ///   - relationship: 관계 (선택)
    ///   - memo: 메모 (선택)
    ///   - isPremium: 프리미엄 구독 여부
    /// - Returns: 추가된 연락처
    /// - Throws: 유효성 검증 실패 또는 추가 실패 시 에러
    func execute(
        ownerUserId: UUID,
        name: String,
        relationship: String?,
        memo: String?,
        isPremium: Bool
    ) async throws -> Contact {
        // 1. 입력 유효성 검증
        try validateInput(name: name, relationship: relationship, memo: memo)
        
        // 2. 현재 연락처 개수 확인
        let currentContacts = try await contactRepository.fetchContacts(forUserId: ownerUserId)
        let contactLimit = ContactLimit(currentCount: currentContacts.count, isPremium: isPremium)
        
        // 3. 추가 가능 여부 검증
        guard contactLimit.canAddContact else {
            throw AddContactError.limitReached(
                current: currentContacts.count,
                max: contactLimit.maxContacts
            )
        }
        
        // 4. 중복 이름 검증
        if currentContacts.contains(where: { $0.name == name }) {
            throw AddContactError.duplicateName
        }
        
        // 5. 연락처 생성
        let contact = Contact(
            id: UUID(),
            ownerUserId: ownerUserId,
            name: name,
            relationship: relationship,
            memo: memo,
            registeredAt: Date()
        )
        
        // 6. 연락처 저장
        return try await contactRepository.addContact(contact)
    }
    
    // MARK: - Private Methods
    
    private func validateInput(
        name: String,
        relationship: String?,
        memo: String?
    ) throws {
        // 이름 검증
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AddContactError.emptyName
        }
        
        guard name.count <= 50 else {
            throw AddContactError.nameTooLong
        }
        
        // 관계 검증 (선택)
        if let relationship = relationship, !relationship.isEmpty {
            guard relationship.count <= 20 else {
                throw AddContactError.relationshipTooLong
            }
        }
        
        // 메모 검증 (선택)
        if let memo = memo, !memo.isEmpty {
            guard memo.count <= 200 else {
                throw AddContactError.memoTooLong
            }
        }
    }
}

// MARK: - Errors

enum AddContactError: Error, LocalizedError {
    case emptyName
    case nameTooLong
    case relationshipTooLong
    case memoTooLong
    case duplicateName
    case limitReached(current: Int, max: Int)
    
    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "이름을 입력해주세요."
        case .nameTooLong:
            return "이름은 최대 50자까지 입력할 수 있습니다."
        case .relationshipTooLong:
            return "관계는 최대 20자까지 입력할 수 있습니다."
        case .memoTooLong:
            return "메모는 최대 200자까지 입력할 수 있습니다."
        case .duplicateName:
            return "이미 등록된 이름입니다."
        case .limitReached(let current, let max):
            return "연락처는 최대 \(max)명까지 등록할 수 있습니다. (현재: \(current)명)"
        }
    }
}
