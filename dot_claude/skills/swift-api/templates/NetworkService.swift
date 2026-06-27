import Foundation
import OSLog

/// Real implementation of {{PROJECT_NAME}}API using URLSession
final class NetworkService: {{PROJECT_NAME}}API {

    // MARK: - Infrastructure

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "\(NetworkService.self)")
    private var lastRefresh = Date.distantPast

    /// Returns the current token, if the token is expired the token is refreshed
    /// - throws: ``ApiError/notAuthenticated`` if the token is not valid or the refreshToken can make an updated refresh, all endpoint and jsonDecoder errors are also rethrown
    private var authToken: String? {
        get async throws {
            guard let authToken = TokenStore.read(type: .access),
                  !authToken.isEmpty,
                  let refreshToken = TokenStore.read(type: .refresh),
                  !refreshToken.isEmpty else {
                return nil
            }

            if lastRefresh.timeIntervalSinceNow > -1  {
                return authToken
            }
            lastRefresh = Date()

            guard authToken.isEmpty || authToken.isExpired else {
                return authToken
            }

            let response = try await endPoint(method: .POST, .v1, .auth, .refresh, headerValues: .refreshToken(refreshToken), token: authToken) as AuthResponse
            TokenStore.save(response.token, type: .access)
            TokenStore.save(response.refreshToken, type: .refresh)

            return response.token
        }
    }

    private static var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration)
    }()


    /// Connect to an endpoint and return an object from that endpoint
    /// - Parameters:
    ///   - method: The HTTP method to use
    ///   - components: list the path to the endpoint, start with the v1
    ///   - body: if the body need a json structure
    ///   - binBody: if the body is already encoded in to a Data object, this will __only__ be used if body == nil, default
    ///   - headerValues: any special header values
    ///   - since: for optimizing the fetch, so already downloaded entities is omitted from the download
    ///   - token: if a special authorization token is needed (JWT added to the "Authorization" key
    /// - Returns: an object of type T from the endpoint
    @MainActor
    @discardableResult
    func endPoint<T: Decodable>(method: ApiMethod = .GET, _ components: ApiComponent..., values: String...,  body: Encodable? = nil, headerValues: Header..., since: Date = .distantPast, token: String? = nil, register: Bool = false) async throws(ApiError) -> T {
        do {
            var token = token
            if token == nil, !register {
                token = try await authToken
            }

            var url = baseURL
            for component in components {
                url.appendPathComponent(component.path)
            }
            for value in values {
                if let encoded = value.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
                    url.appendPathComponent(encoded)
                } else {
                    throw ApiError.invalidData
                }
            }

            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method.rawValue

            urlRequest.addValue(Header.apiKey.value, forHTTPHeaderField: Header.apiKey.key)
            urlRequest.addValue(Header.appName.value, forHTTPHeaderField: Header.appName.key)
            urlRequest.addValue(Header.build.value, forHTTPHeaderField: Header.build.key)
            urlRequest.addValue(Header.appVersion.value, forHTTPHeaderField: Header.appVersion.key)
            urlRequest.addValue(Header.contentType.value, forHTTPHeaderField: Header.contentType.key)
            urlRequest.addValue(Header.language.value, forHTTPHeaderField: Header.language.key)

            let header = Header.since(since)
            urlRequest.addValue(header.value, forHTTPHeaderField: header.key)

            for headerValue in headerValues {
                urlRequest.addValue(headerValue.value, forHTTPHeaderField: headerValue.key)
            }

            if let token {
                let header = Header.authorization(token)
                urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
            }

            urlRequest.httpBody = body?.json

            let (data, response) = try await Self.urlSession.data(for: urlRequest)

            guard response.http.isSuccess else {
                if response.http.notModified {
                    throw ApiError.notModified
                }
                throw response.http
            }

            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            logger.error("Error communicating with the server: \(error as NSError)")
            throw error as? ApiError ?? .passThrough(error)
        }
    }

    var baseURL: URL {
        if let serverURLString = ProcessInfo.processInfo.environment["SERVER_URL"] {
            return URL(string: serverURLString)!
        }
        #if DEBUG
        return URL(string: "{{BASE_URL_DEBUG}}")!
        #elseif BETA
        return URL(string: "{{BASE_URL_BETA}}")!
        #else
        return URL(string: "{{BASE_URL_PRODUCTION}}")!
        #endif
    }
}

typealias HttpHeader = [Header: Header]

enum Header: Hashable {
    var value: String {
        switch self {
        case .apiKey: "{{API_KEY}}"
        case .appName: Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "App"
        case .build:  Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        case .appVersion: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0.0.0"
        case .refreshToken(let token): token
        case .contentType, .appplicationJson: "application/json"
        case .authorization(let token): token?.bearer ?? ""
        case .custom(key: _, value: let value): value
        case .since(let since): "\(Int(since.timeIntervalSinceReferenceDate))"
        case .language: Locale.current.language.languageCode?.identifier ?? "en"
#if DEBUG
        case .sandbox: "true"
#else
        case .sandbox: "false"
#endif
        }
    }

    var key: String {
        switch self {
        case .refreshToken(_): "X-Refresh-Token"
        case .contentType, .appplicationJson: "Content-Type"
        case .appVersion: "AppVersion"
        case .appName: "AppName"
        case .build: "AppBuild"
        case .authorization: "Authorization"
        case .apiKey: "x-api-key"
        case .since: "since"
        case .language: "language"
        case .sandbox: "X-APNs-Sandbox"
        case .custom(let key, _): key
        }
    }

    case refreshToken(String)
    case apiKey
    case contentType
    case appVersion
    case appName
    case build
    case authorization(JWT?)
    case appplicationJson
    case language
    case since(Date)
    case custom(key: String, value: String)
    case sandbox
}

enum ApiMethod: String {
    case GET, POST, PUT, PATCH, DELETE
}

enum ApiComponent: String {
    var path: String {
        switch self {
        default: rawValue
        }
    }

    case v1

    // MARK: - Auth Endpoints (Always included)
    case auth,
         signIn,
         free,
         apple,
         refresh,
         signOut

    // MARK: - Generated Endpoints (from OpenAPI spec)
    {{ADDITIONAL_COMPONENTS}}
    // MARK: - End Generated Endpoints
}

struct GenericApiResponse: Codable {
    var message: String?
}

enum ApiError: Error {
    case passThrough(Error)
    case invalidResponse, invalidData
    case invalidUserProfile, invalidAppleUser, notAuthenticated
    case notModified
    case notImplemented
}

typealias JWT = String

extension JWT {
    var bearer: String {
        "Bearer \(self)"
    }

    var isExpired: Bool {
        do {
            let jwt = try decode(jwt: self)
            return jwt.expired
        } catch {
            return true
        }
    }
}
