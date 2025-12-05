//
//  SignupUseCase.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 회원가입 Use Case
/// 사용자 회원가입 비즈니스 로직을 담당
struct SignupUseCase {
    // MARK: - Dependencies
    
    private let authRepository: AuthRepositoryInterface
    
    // MARK: - Initialization
    
    init(authRepository: AuthRepositoryInterface) {
        self.authRepository = authRepository
    }
    
    // MARK: - Execution
    
    /// 회원가입 실행
    /// - Parameters:
    ///   - username: 사용자 이름
    ///   - email: 이메일 주소
    ///   - password: 비밀번호
    ///   - passwordConfirmation: 비밀번호 확인
    /// - Returns: 생성된 사용자
    /// - Throws: 유효성 검증 실패 또는 회원가입 실패 시 에러
    func execute(
        username: String,
        email: String,
        password: String,
        passwordConfirmation: String
    ) async throws -> User {
        // 1. 입력 유효성 검증
        try validateInput(
            username: username,
            email: email,
            password: password,
            passwordConfirmation: passwordConfirmation
        )
        
        // 2. 회원가입 실행
        let user = try await authRepository.signup(
            username: username,
            email: email,
            password: password
        )
        
        return user
    }
    
    // MARK: - Private Methods
    
    private func validateInput(
        username: String,
        email: String,
        password: String,
        passwordConfirmation: String
    ) throws {
        // 사용자 이름 검증
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw SignupError.emptyUsername
        }
        
        guard username.count >= 2 else {
            throw SignupError.usernameTooShort
        }
        
        guard username.count <= 20 else {
            throw SignupError.usernameTooLong
        }
        
        // 이메일 검증
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw SignupError.emptyEmail
        }
        
        guard isValidEmail(email) else {
            throw SignupError.invalidEmailFormat
        }
        
        // 비밀번호 검증
        guard !password.isEmpty else {
            throw SignupError.emptyPassword
        }
        
        guard password.count >= 8 else {
            throw SignupError.passwordTooShort
        }
        
        guard password.count <= 50 else {
            throw SignupError.passwordTooLong
        }
        
        guard hasValidPasswordPattern(password) else {
            throw SignupError.weakPassword
        }
        
        // 비밀번호 확인 검증
        guard password == passwordConfirmation else {
            throw SignupError.passwordMismatch
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func hasValidPasswordPattern(_ password: String) -> Bool {
        // 최소 하나의 문자와 하나의 숫자 포함
        let hasLetter = password.range(of: "[A-Za-z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        return hasLetter && hasNumber
    }
}

// MARK: - Errors

enum SignupError: Error, LocalizedError {
    case emptyUsername
    case usernameTooShort
    case usernameTooLong
    case emptyEmail
    case invalidEmailFormat
    case emailAlreadyExists
    case emptyPassword
    case passwordTooShort
    case passwordTooLong
    case weakPassword
    case passwordMismatch
    
    var errorDescription: String? {
        switch self {
        case .emptyUsername:
            return "사용자 이름을 입력해주세요."
        case .usernameTooShort:
            return "사용자 이름은 최소 2자 이상이어야 합니다."
        case .usernameTooLong:
            return "사용자 이름은 최대 20자까지 가능합니다."
        case .emptyEmail:
            return "이메일을 입력해주세요."
        case .invalidEmailFormat:
            return "올바른 이메일 형식이 아닙니다."
        case .emailAlreadyExists:
            return "이미 사용 중인 이메일입니다."
        case .emptyPassword:
            return "비밀번호를 입력해주세요."
        case .passwordTooShort:
            return "비밀번호는 최소 8자 이상이어야 합니다."
        case .passwordTooLong:
            return "비밀번호는 최대 50자까지 가능합니다."
        case .weakPassword:
            return "비밀번호는 문자와 숫자를 포함해야 합니다."
        case .passwordMismatch:
            return "비밀번호가 일치하지 않습니다."
        }
    }
}
