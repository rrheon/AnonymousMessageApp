//
//  PersonalLink.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 개인 링크 Value Object
/// 사용자가 쪽지를 받을 수 있는 고유 링크를 나타냄
struct PersonalLink: Equatable {
    /// 사용자 ID
    let userId: UUID
    
    /// 고유 토큰
    let token: String
    
    /// 기본 도메인
    private static let baseDomain = "https://app.anonymous-message.com"
    
    /// 전체 URL
    var url: URL {
        URL(string: "\(Self.baseDomain)/receive/\(token)")!
    }
    
    /// 공유 가능한 텍스트
    var shareableText: String {
        """
        익명으로 쪽지를 보내주세요! 📝
        \(url.absoluteString)
        """
    }
    
    /// 짧은 공유 텍스트
    var shortShareText: String {
        "익명 쪽지: \(url.absoluteString)"
    }
    
    /// 토큰 유효성 검증
    var isValid: Bool {
        !token.isEmpty && token.count >= 8
    }
}

// MARK: - Factory Methods
extension PersonalLink {
    /// 새로운 개인 링크 생성
    static func generate(for userId: UUID) -> PersonalLink {
        let token = generateToken()
        return PersonalLink(userId: userId, token: token)
    }
    
    /// 랜덤 토큰 생성
    private static func generateToken() -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<32).map { _ in characters.randomElement()! })
    }
}

// MARK: - Mock Data (테스트용)
#if DEBUG
extension PersonalLink {
    static func mock(
        userId: UUID = UUID(),
        token: String? = nil
    ) -> PersonalLink {
        PersonalLink(
            userId: userId,
            token: token ?? "mock-token-\(userId.uuidString.prefix(8))"
        )
    }
}
#endif
