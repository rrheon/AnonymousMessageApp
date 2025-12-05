//
//  AuthRepositoryInterface.swift
//  AnonymousMessageApp
//
//  Created on 2025-12-05.
//

import Foundation

/// 인증 Repository 인터페이스
/// 사용자 인증 관련 데이터 접근을 위한 프로토콜
protocol AuthRepositoryInterface {
    /// 로그인
    /// - Parameters:
    ///   - email: 이메일 주소
    ///   - password: 비밀번호
    /// - Returns: 로그인한 사용자 정보
    /// - Throws: 로그인 실패 시 에러
    func login(email: String, password: String) async throws -> User
    
    /// 회원가입
    /// - Parameters:
    ///   - username: 사용자 이름
    ///   - email: 이메일 주소
    ///   - password: 비밀번호
    /// - Returns: 생성된 사용자 정보
    /// - Throws: 회원가입 실패 시 에러
    func signup(username: String, email: String, password: String) async throws -> User
    
    /// 로그아웃
    /// - Throws: 로그아웃 실패 시 에러
    func logout() async throws
    
    /// 현재 로그인한 사용자 조회
    /// - Returns: 현재 사용자 (로그인하지 않은 경우 nil)
    /// - Throws: 조회 실패 시 에러
    func getCurrentUser() async throws -> User?
    
    /// 로그인 상태 확인
    /// - Returns: 로그인 여부
    func isAuthenticated() async -> Bool
}
