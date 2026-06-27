# Swift API Network Layer - Quick Start

## 1. Generate from OpenAPI/Scalar spec

```bash
# In Claude Code, write:
"Create Swift API client from my Scalar spec: https://api.example.com/openapi.json"
```

The skill will:
- ✅ Read the spec
- ✅ Generate all files (Protocol, NetworkService, Mock, Helpers, Models)
- ✅ Ask where to save the files

## 2. Add Swift Package dependency

**IMPORTANT**: After generation you need to add the Auth0 JWTDecode package.

### In Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/auth0/JWTDecode.swift`
3. Version: 3.0.0+
4. Add to target

### Or in Package.swift:
```swift
dependencies: [
    .package(url: "https://github.com/auth0/JWTDecode.swift", from: "3.0.0")
]
```

## 3. Use in your app

```swift
import Foundation

// Create service instance
let api = NetworkService()

// Call endpoint
let user: User = try await api.endPoint(
    method: .GET,
    .v1, .users,
    values: "123"
)

// With auth
let production: Production = try await api.endPoint(
    method: .POST,
    .v1, .productions,
    body: CreateProductionRequest(name: "My Show")
)
```

## 4. Test with Mock

```swift
import XCTest

class APITests: XCTestCase {
    var mockAPI: MockNetworkService!

    override func setUp() {
        mockAPI = MockNetworkService()
    }

    func testGetUser() async throws {
        // Set mock response
        mockAPI.mockResponse = User(id: "123", name: "Test")

        // Call endpoint
        let user: User = try await mockAPI.endPoint(
            method: .GET,
            .v1, .users,
            values: "123"
        )

        // Verify
        XCTAssertEqual(user.name, "Test")
        XCTAssertEqual(mockAPI.recordedCalls.count, 1)
        XCTAssertEqual(mockAPI.recordedCalls[0].method, .GET)
    }
}
```

## 5. Update when backend changes

```bash
# In Claude Code:
"Update my Swift API from: https://api.example.com/openapi.json"
```

The skill will:
- ✅ Compare new spec with existing files
- ✅ Show diff (added/removed/changed)
- ✅ Ask before updating
- ✅ Preserve your custom code

## Common use cases

### Custom endpoint (preserved during updates)
```swift
enum ApiComponent: String {
    // MARK: - Generated Endpoints
    case users, productions
    // MARK: - End Generated Endpoints

    // Your custom endpoint here - preserved automatically:
    case myCustomEndpoint

    var path: String {
        switch self {
        case .myCustomEndpoint: return "custom/path"
        default: return rawValue
        }
    }
}
```

### Custom header
```swift
let customHeader = Header.custom(key: "X-Custom-Header", value: "value")
let user: User = try await api.endPoint(
    method: .GET,
    .v1, .users,
    headerValues: customHeader
)
```

### Offline mode / No auth
```swift
let response: PublicData = try await api.endPoint(
    method: .GET,
    .v1, .public, .data,
    token: nil,
    register: true  // Skip auth check
)
```

## Troubleshooting

### "Cannot find 'JWTDecode' in scope"
→ Remember to add Auth0 JWTDecode package (see step 2)

### "Token expired" errors
→ Auto-refresh is built-in, but check that TokenStore has valid refresh token

### Update overwrites my code
→ Make sure custom code is OUTSIDE `// MARK: - Generated` sections

## Environment configuration

Use environment variable to override base URL:
```swift
// In scheme settings:
SERVER_URL = "http://localhost:3000"
```

Or use build configurations:
- DEBUG: Debug URL from OpenAPI spec
- BETA: Beta URL from OpenAPI spec
- RELEASE: Production URL from OpenAPI spec

## Tips

1. ✅ Commit before updating (so you can see diff)
2. ✅ Test mock service after update
3. ✅ Place custom endpoints OUTSIDE generated sections
4. ✅ Use OpenAPI specs when possible (keeps everything synchronized)
