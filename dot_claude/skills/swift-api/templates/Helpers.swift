import Foundation
import JWTDecode

// MARK: - Encodable Extension

extension Encodable {
    var json: Data? {
        try? JSONEncoder().encode(self)
    }
}

// MARK: - URLResponse Extension

extension URLResponse {
    var http: HTTPURLResponse {
        self as? HTTPURLResponse ?? HTTPURLResponse()
    }
}

// MARK: - HTTPURLResponse Extension

extension HTTPURLResponse {
    var isSuccess: Bool {
        (200...299).contains(statusCode)
    }

    var notModified: Bool {
        statusCode == 304
    }
}

// MARK: - JWT Decoding (using Auth0 JWTDecode)

struct JWTPayload {
    let exp: TimeInterval
    let iat: TimeInterval?
    let sub: String?

    var expired: Bool {
        Date(timeIntervalSince1970: exp) < Date()
    }

    init(jwt: JWT) throws {
        let decoded = try decode(jwt: jwt)

        guard let exp = decoded.expiresAt?.timeIntervalSince1970 else {
            throw ApiError.invalidData
        }

        self.exp = exp
        self.iat = decoded.issuedAt?.timeIntervalSince1970
        self.sub = decoded.subject
    }
}

func decode(jwt: String) throws -> JWTDecode.JWT {
    do {
        return try JWTDecode.decode(jwt: jwt)
    } catch {
        throw ApiError.invalidData
    }
}

// MARK: - TokenStore

enum TokenType {
    case access
    case refresh
}

struct TokenStore {
    private static let accessTokenKey = "{{PROJECT_NAME}}_access_token"
    private static let refreshTokenKey = "{{PROJECT_NAME}}_refresh_token"

    static func save(_ token: String, type: TokenType) {
        let key = type == .access ? accessTokenKey : refreshTokenKey
        UserDefaults.standard.set(token, forKey: key)
    }

    static func read(type: TokenType) -> String? {
        let key = type == .access ? accessTokenKey : refreshTokenKey
        return UserDefaults.standard.string(forKey: key)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
    }
}

// MARK: - Auth Response

struct AuthResponse: Codable {
    let token: String
    let refreshToken: String
}
