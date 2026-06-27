import Foundation

/// Mock implementation of {{PROJECT_NAME}}API for testing
final class MockNetworkService: {{PROJECT_NAME}}API {

    var mockResponse: Any?
    var mockError: ApiError?
    var recordedCalls: [(method: ApiMethod, components: [ApiComponent], values: [String])] = []

    @MainActor
    @discardableResult
    func endPoint<T: Decodable>(
        method: ApiMethod = .GET,
        _ components: ApiComponent...,
        values: String... = [],
        body: Encodable? = nil,
        headerValues: Header... = [],
        since: Date = .distantPast,
        token: String? = nil,
        register: Bool = false
    ) async throws(ApiError) -> T {

        // Record the call for testing verification
        recordedCalls.append((method, components, values))

        // Throw mock error if set
        if let mockError {
            throw mockError
        }

        // Return mock response if available
        if let mockResponse = mockResponse as? T {
            return mockResponse
        }

        // Try to decode from mock JSON data
        if let mockResponse = mockResponse as? Data {
            return try JSONDecoder().decode(T.self, from: mockResponse)
        }

        throw ApiError.notImplemented
    }

    var baseURL: URL {
        URL(string: "https://mock.api.example.com")!
    }

    func reset() {
        mockResponse = nil
        mockError = nil
        recordedCalls.removeAll()
    }
}
