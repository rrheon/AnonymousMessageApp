//
//  LoginUseCase.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 로그인 Use Case
/// 사용자 로그인 비즈니스 로직을 담당
struct LoginUseCase {
    // MARK: - Dependencies
    
    private let authRepository: AuthRepositoryInterface
    
    // MARK: - Initialization
    
    init(authRepository: AuthRepositoryInterface) {
        self.authRepository = authRepository
    }
    
    // MARK: - Execution
    
    /// 로그인 실행
    /// - Parameters:
    ///   - email: 이메일 주소
    ///   - password: 비밀번호
    /// - Returns: 로그인한 사용자
    /// - Throws: 유효성 검증 실패 또는 로그인 실패 시 에러
    func execute(email: String, password: String) async throws -> User {
        // 1. 입력 유효성 검증
        try validateInput(email: email, password: password)
        
        // 2. 로그인 실행
        let user = try await authRepository.login(email: email, password: password)
        
        return user
    }
    
    // MARK: - Private Methods
    
    private func validateInput(email: String, password: String) throws {
        // 이메일 검증
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw LoginError.emptyEmail
        }
        
        guard isValidEmail(email) else {
            throw LoginError.invalidEmailFormat
        }
        
        // 비밀번호 검증
        guard !password.isEmpty else {
            throw LoginError.emptyPassword
        }
        
        guard password.count >= 6 else {
            throw LoginError.passwordTooShort
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

// MARK: - Errors

enum LoginError: Error, LocalizedError {
    case emptyEmail
    case invalidEmailFormat
    case emptyPassword
    case passwordTooShort
    case invalidCredentials
    case userNotFound
    case accountLocked
    
    var errorDescription: String? {
        switch self {
        case .emptyEmail:
            return "이메일을 입력해주세요."
        case .invalidEmailFormat:
            return "올바른 이메일 형식이 아닙니다."
        case .emptyPassword:
            return "비밀번호를 입력해주세요."
        case .passwordTooShort:
            return "비밀번호는 최소 6자 이상이어야 합니다."
        case .invalidCredentials:
            return "이메일 또는 비밀번호가 올바르지 않습니다."
        case .userNotFound:
            return "등록되지 않은 사용자입니다."
        case .accountLocked:
            return "계정이 잠겼습니다. 고객센터에 문의해주세요."
        }
    }
}
