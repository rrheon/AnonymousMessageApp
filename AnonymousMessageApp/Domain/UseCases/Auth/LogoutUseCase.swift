//
//  LogoutUseCase.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 로그아웃 Use Case
/// 사용자 로그아웃 비즈니스 로직을 담당
struct LogoutUseCase {
    // MARK: - Dependencies
    
    private let authRepository: AuthRepositoryInterface
    
    // MARK: - Initialization
    
    init(authRepository: AuthRepositoryInterface) {
        self.authRepository = authRepository
    }
    
    // MARK: - Execution
    
    /// 로그아웃 실행
    /// - Throws: 로그아웃 실패 시 에러
    func execute() async throws {
        // 1. 인증 상태 확인
        let isAuthenticated = await authRepository.isAuthenticated()
        guard isAuthenticated else {
            throw LogoutError.notAuthenticated
        }
        
        // 2. 로그아웃 실행
        try await authRepository.logout()
    }
}

// MARK: - Errors

enum LogoutError: Error, LocalizedError {
    case notAuthenticated
    case logoutFailed
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "로그인 상태가 아닙니다."
        case .logoutFailed:
            return "로그아웃에 실패했습니다."
        }
    }
}
