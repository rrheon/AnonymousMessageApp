//
//  UpdateContactUseCase.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 연락처 업데이트 Use Case
/// 연락처 정보 수정 비즈니스 로직을 담당
struct UpdateContactUseCase {
    // MARK: - Dependencies
    
    private let contactRepository: ContactRepositoryInterface
    
    // MARK: - Initialization
    
    init(contactRepository: ContactRepositoryInterface) {
        self.contactRepository = contactRepository
    }
    
    // MARK: - Execution
    
    /// 연락처 업데이트 실행
    /// - Parameters:
    ///   - contactId: 업데이트할 연락처 ID
    ///   - name: 새 이름 (nil이면 변경하지 않음)
    ///   - relationship: 새 관계 (nil이면 변경하지 않음)
    ///   - memo: 새 메모 (nil이면 변경하지 않음)
    /// - Returns: 업데이트된 연락처
    /// - Throws: 유효성 검증 실패 또는 업데이트 실패 시 에러
    func execute(
        contactId: UUID,
        name: String?,
        relationship: String?,
        memo: String?
    ) async throws -> Contact {
        // 1. 기존 연락처 조회
        let existingContact = try await contactRepository.fetchContact(byId: contactId)
        
        // 2. 업데이트할 값 결정
        let updatedName = name ?? existingContact.name
        let updatedRelationship = relationship ?? existingContact.relationship
        let updatedMemo = memo ?? existingContact.memo
        
        // 3. 유효성 검증
        try validateInput(name: updatedName, relationship: updatedRelationship, memo: updatedMemo)
        
        // 4. 중복 이름 검증 (이름이 변경된 경우)
        if let newName = name, newName != existingContact.name {
            let allContacts = try await contactRepository.fetchContacts(forUserId: existingContact.ownerUserId)
            if allContacts.contains(where: { $0.name == newName && $0.id != contactId }) {
                throw UpdateContactError.duplicateName
            }
        }
        
        // 5. 업데이트된 연락처 생성
        let updatedContact = Contact(
            id: existingContact.id,
            ownerUserId: existingContact.ownerUserId,
            name: updatedName,
            relationship: updatedRelationship,
            memo: updatedMemo,
            registeredAt: existingContact.registeredAt
        )
        
        // 6. 업데이트 실행
        return try await contactRepository.updateContact(updatedContact)
    }
    
    // MARK: - Private Methods
    
    private func validateInput(
        name: String,
        relationship: String?,
        memo: String?
    ) throws {
        // 이름 검증
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw UpdateContactError.emptyName
        }
        
        guard name.count <= 50 else {
            throw UpdateContactError.nameTooLong
        }
        
        // 관계 검증 (선택)
        if let relationship = relationship, !relationship.isEmpty {
            guard relationship.count <= 20 else {
                throw UpdateContactError.relationshipTooLong
            }
        }
        
        // 메모 검증 (선택)
        if let memo = memo, !memo.isEmpty {
            guard memo.count <= 200 else {
                throw UpdateContactError.memoTooLong
            }
        }
    }
}

// MARK: - Errors

enum UpdateContactError: Error, LocalizedError {
    case emptyName
    case nameTooLong
    case relationshipTooLong
    case memoTooLong
    case duplicateName
    case contactNotFound
    case updateFailed
    
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
        case .contactNotFound:
            return "연락처를 찾을 수 없습니다."
        case .updateFailed:
            return "연락처 업데이트에 실패했습니다."
        }
    }
}
