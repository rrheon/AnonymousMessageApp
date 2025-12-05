//
//  UserRepositoryInterface.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 사용자 Repository 인터페이스
/// 사용자 데이터 접근을 위한 프로토콜
protocol UserRepositoryInterface {
    /// 현재 로그인한 사용자 조회
    /// - Returns: 현재 사용자
    /// - Throws: 인증되지 않은 경우 에러
    func fetchCurrentUser() async throws -> User
    
    /// 사용자 정보 업데이트
    /// - Parameter user: 업데이트할 사용자 정보
    /// - Returns: 업데이트된 사용자
    /// - Throws: 업데이트 실패 시 에러
    func updateUser(_ user: User) async throws -> User
    
    /// ID로 사용자 조회
    /// - Parameter id: 사용자 ID
    /// - Returns: 조회된 사용자
    /// - Throws: 사용자를 찾을 수 없는 경우 에러
    func fetchUser(byId id: UUID) async throws -> User
    
    /// 개인 링크로 사용자 조회
    /// - Parameter link: 개인 링크 토큰
    /// - Returns: 조회된 사용자
    /// - Throws: 사용자를 찾을 수 없는 경우 에러
    func fetchUser(byPersonalLink link: String) async throws -> User
}
