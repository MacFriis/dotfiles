import Foundation

/// Protocol defining the {{PROJECT_NAME}} API interface
protocol {{PROJECT_NAME}}API {
    /// Connect to an endpoint and return an object from that endpoint
    /// - Parameters:
    ///   - method: The HTTP method to use
    ///   - components: list the path to the endpoint, start with the v1
    ///   - values: additional path components
    ///   - body: if the body need a json structure
    ///   - headerValues: any special header values
    ///   - since: for optimizing the fetch, so already downloaded entities is omitted from the download
    ///   - token: if a special authorization token is needed (JWT added to the "Authorization" key
    ///   - register: whether this is a registration request
    /// - Returns: an object of type T from the endpoint
    @MainActor
    @discardableResult
    func endPoint<T: Decodable>(
        method: ApiMethod,
        _ components: ApiComponent...,
        values: String...,
        body: Encodable?,
        headerValues: Header...,
        since: Date,
        token: String?,
        register: Bool
    ) async throws(ApiError) -> T

    var baseURL: URL { get }
}
