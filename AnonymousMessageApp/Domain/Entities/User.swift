//
//  User.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 사용자 엔티티
/// 앱의 사용자를 나타내는 도메인 모델
struct User: Equatable, Identifiable {
    /// 사용자 고유 ID
    let id: UUID
    
    /// 사용자 이름
    let username: String
    
    /// 이메일 주소
    let email: String
    
    /// 프로필 이미지 URL (선택)
    let profileImageURL: URL?
    
    /// 쪽지 수신용 개인 링크
    let personalLink: PersonalLink
    
    /// 계정 생성일
    let createdAt: Date
    
    /// 표시용 이름
    var displayName: String {
        username
    }
}

// MARK: - Mock Data (테스트용)
#if DEBUG
extension User {
    static func mock(
        id: UUID = UUID(),
        username: String = "테스트사용자",
        email: String = "test@example.com",
        profileImageURL: URL? = nil,
        personalLink: PersonalLink? = nil,
        createdAt: Date = Date()
    ) -> User {
        User(
            id: id,
            username: username,
            email: email,
            profileImageURL: profileImageURL,
            personalLink: personalLink ?? PersonalLink(userId: id, token: "mock-token-\(id.uuidString.prefix(8))"),
            createdAt: createdAt
        )
    }
}
#endif
