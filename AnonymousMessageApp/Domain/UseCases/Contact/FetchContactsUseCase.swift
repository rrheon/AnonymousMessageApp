//
//  FetchContactsUseCase.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 연락처 목록 조회 Use Case
/// 연락처 목록 조회 비즈니스 로직을 담당
struct FetchContactsUseCase {
    // MARK: - Dependencies
    
    private let contactRepository: ContactRepositoryInterface
    
    // MARK: - Initialization
    
    init(contactRepository: ContactRepositoryInterface) {
        self.contactRepository = contactRepository
    }
    
    // MARK: - Execution
    
    /// 연락처 목록 조회 실행
    /// - Parameter userId: 사용자 ID
    /// - Returns: 연락처 목록
    /// - Throws: 조회 실패 시 에러
    func execute(userId: UUID) async throws -> [Contact] {
        let contacts = try await contactRepository.fetchContacts(forUserId: userId)
        return sortContacts(contacts)
    }
    
    /// 삭제 가능한 연락처 목록 조회
    /// - Parameter userId: 사용자 ID
    /// - Returns: 삭제 가능한 연락처 목록
    /// - Throws: 조회 실패 시 에러
    func fetchDeletableContacts(userId: UUID) async throws -> [Contact] {
        let contacts = try await execute(userId: userId)
        return contacts.filter { $0.isDeletable }
    }
    
    /// 삭제 불가능한 연락처 목록 조회
    /// - Parameter userId: 사용자 ID
    /// - Returns: 삭제 불가능한 연락처 목록
    /// - Throws: 조회 실패 시 에러
    func fetchLockedContacts(userId: UUID) async throws -> [Contact] {
        let contacts = try await execute(userId: userId)
        return contacts.filter { !$0.isDeletable }
    }
    
    // MARK: - Private Methods
    
    /// 연락처 정렬
    /// - Parameter contacts: 정렬할 연락처 목록
    /// - Returns: 정렬된 연락처 목록
    /// - Note: 등록일 최신순으로 정렬
    private func sortContacts(_ contacts: [Contact]) -> [Contact] {
        contacts.sorted { $0.registeredAt > $1.registeredAt }
    }
}
