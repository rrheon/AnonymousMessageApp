//
//  UpdateUserProfileUseCase.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 사용자 프로필 업데이트 Use Case
/// 사용자 프로필 업데이트 비즈니스 로직을 담당
struct UpdateUserProfileUseCase {
    // MARK: - Dependencies
    
    private let userRepository: UserRepositoryInterface
    
    // MARK: - Initialization
    
    init(userRepository: UserRepositoryInterface) {
        self.userRepository = userRepository
    }
    
    // MARK: - Execution
    
    /// 프로필 업데이트 실행
    /// - Parameters:
    ///   - userId: 업데이트할 사용자 ID
    ///   - username: 새 사용자 이름 (nil이면 변경하지 않음)
    ///   - profileImageURL: 새 프로필 이미지 URL (nil이면 변경하지 않음)
    /// - Returns: 업데이트된 사용자
    /// - Throws: 유효성 검증 실패 또는 업데이트 실패 시 에러
    func execute(
        userId: UUID,
        username: String?,
        profileImageURL: URL?
    ) async throws -> User {
        // 1. 기존 사용자 조회
        let existingUser = try await userRepository.fetchUser(byId: userId)
        
        // 2. 업데이트할 값 결정
        let updatedUsername = username ?? existingUser.username
        let updatedProfileImageURL = profileImageURL ?? existingUser.profileImageURL
        
        // 3. 사용자 이름 유효성 검증
        if let newUsername = username {
            try validateUsername(newUsername)
        }
        
        // 4. 업데이트된 사용자 생성
        let updatedUser = User(
            id: existingUser.id,
            username: updatedUsername,
            email: existingUser.email,
            profileImageURL: updatedProfileImageURL,
            personalLink: existingUser.personalLink,
            createdAt: existingUser.createdAt
        )
        
        // 5. 업데이트 실행
        return try await userRepository.updateUser(updatedUser)
    }
    
    /// 프로필 이미지만 업데이트
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - profileImageURL: 새 프로필 이미지 URL
    /// - Returns: 업데이트된 사용자
    /// - Throws: 업데이트 실패 시 에러
    func updateProfileImage(userId: UUID, profileImageURL: URL?) async throws -> User {
        try await execute(userId: userId, username: nil, profileImageURL: profileImageURL)
    }
    
    /// 사용자 이름만 업데이트
    /// - Parameters:
    ///   - userId: 사용자 ID
    ///   - username: 새 사용자 이름
    /// - Returns: 업데이트된 사용자
    /// - Throws: 업데이트 실패 시 에러
    func updateUsername(userId: UUID, username: String) async throws -> User {
        try await execute(userId: userId, username: username, profileImageURL: nil)
    }
    
    // MARK: - Private Methods
    
    private func validateUsername(_ username: String) throws {
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedUsername.isEmpty else {
            throw UpdateUserProfileError.emptyUsername
        }
        
        guard trimmedUsername.count >= 2 else {
            throw UpdateUserProfileError.usernameTooShort
        }
        
        guard trimmedUsername.count <= 20 else {
            throw UpdateUserProfileError.usernameTooLong
        }
    }
}

// MARK: - Errors

enum UpdateUserProfileError: Error, LocalizedError {
    case emptyUsername
    case usernameTooShort
    case usernameTooLong
    case userNotFound
    case updateFailed
    
    var errorDescription: String? {
        switch self {
        case .emptyUsername:
            return "사용자 이름을 입력해주세요."
        case .usernameTooShort:
            return "사용자 이름은 최소 2자 이상이어야 합니다."
        case .usernameTooLong:
            return "사용자 이름은 최대 20자까지 가능합니다."
        case .userNotFound:
            return "사용자를 찾을 수 없습니다."
        case .updateFailed:
            return "프로필 업데이트에 실패했습니다."
        }
    }
}
