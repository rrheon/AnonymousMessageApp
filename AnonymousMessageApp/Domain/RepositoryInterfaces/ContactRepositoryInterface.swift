//
//  ContactRepositoryInterface.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 연락처 Repository 인터페이스
/// 연락처 데이터 접근을 위한 프로토콜
protocol ContactRepositoryInterface {
    /// 사용자의 모든 연락처 조회
    /// - Parameter userId: 사용자 ID
    /// - Returns: 연락처 목록
    /// - Throws: 조회 실패 시 에러
    func fetchContacts(forUserId userId: UUID) async throws -> [Contact]
    
    /// ID로 연락처 조회
    /// - Parameter id: 연락처 ID
    /// - Returns: 조회된 연락처
    /// - Throws: 연락처를 찾을 수 없는 경우 에러
    func fetchContact(byId id: UUID) async throws -> Contact
    
    /// 연락처 추가
    /// - Parameter contact: 추가할 연락처
    /// - Returns: 추가된 연락처
    /// - Throws: 추가 실패 시 에러
    func addContact(_ contact: Contact) async throws -> Contact
    
    /// 연락처 삭제
    /// - Parameter id: 삭제할 연락처 ID
    /// - Throws: 삭제 실패 시 에러
    func deleteContact(byId id: UUID) async throws
    
    /// 연락처 업데이트
    /// - Parameter contact: 업데이트할 연락처
    /// - Returns: 업데이트된 연락처
    /// - Throws: 업데이트 실패 시 에러
    func updateContact(_ contact: Contact) async throws -> Contact
}
