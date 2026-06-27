//
//  TokenStore.swift
//  
//

import Foundation

struct TokenStore {
    static func save(_ token: String, type: TokenType) {
        KeychainHelper.save(token, key: type.rawValue)
    }

    static func read(type: TokenType) -> String? {
        KeychainHelper.read(key: type.rawValue)
    }

    static func clearAll() {
        KeychainHelper.delete(key: TokenType.access.rawValue)
        KeychainHelper.delete(key: TokenType.refresh.rawValue)
        KeychainHelper.delete(key: TokenType.provider.rawValue)
        KeychainHelper.delete(key: TokenType.userId.rawValue)
    }
}

enum TokenType: String {
    case userId
    case access
    case refresh
    case provider
}