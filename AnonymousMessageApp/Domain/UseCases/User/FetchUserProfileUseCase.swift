//
//  FetchUserProfileUseCase.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 사용자 프로필 조회 Use Case
/// 사용자 프로필 조회 비즈니스 로직을 담당
struct FetchUserProfileUseCase {
    // MARK: - Dependencies
    
    private let userRepository: UserRepositoryInterface
    
    // MARK: - Initialization
    
    init(userRepository: UserRepositoryInterface) {
        self.userRepository = userRepository
    }
    
    // MARK: - Execution
    
    /// 현재 사용자 프로필 조회
    /// - Returns: 현재 사용자
    /// - Throws: 조회 실패 시 에러
    func executeForCurrentUser() async throws -> User {
        try await userRepository.fetchCurrentUser()
    }
    
    /// ID로 사용자 프로필 조회
    /// - Parameter userId: 사용자 ID
    /// - Returns: 조회된 사용자
    /// - Throws: 조회 실패 시 에러
    func execute(userId: UUID) async throws -> User {
        try await userRepository.fetchUser(byId: userId)
    }
    
    /// 개인 링크로 사용자 조회
    /// - Parameter personalLink: 개인 링크 토큰
    /// - Returns: 조회된 사용자
    /// - Throws: 조회 실패 시 에러
    func execute(personalLink: String) async throws -> User {
        try await userRepository.fetchUser(byPersonalLink: personalLink)
    }
}
