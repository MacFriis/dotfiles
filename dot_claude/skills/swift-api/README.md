# Swift API Network Layer Skill

Automatic generation of Swift REST API clients from OpenAPI/Swagger/Scalar specs.

## Features

- **OpenAPI/Swagger/Scalar support**: Reads specs (JSON/YAML) and automatically generates endpoints and models
- **Smart updates**: Can update existing API clients when backend changes
- **Full infrastructure**: JWT auth with auto-refresh, token management, logging, error handling
- **Mock support**: Automatically generated mock service for testing
- **Type-safe**: Generates Swift structs from OpenAPI schemas with correct type mapping

## How to use the skill

### 1. Generate new API client from OpenAPI spec

```
User: "Create Swift API client from my OpenAPI spec: https://api.example.com/openapi.json"
```

The skill will:
1. Fetch the OpenAPI spec
2. Parse endpoints and models
3. Ask about project name, where to save files
4. Generate all necessary files

### 2. Update existing API client

```
User: "Update my Swift API - backend has new endpoints"
or
User: "My Scalar spec is updated: https://api.example.com/openapi.json"
```

The skill will:
1. Read the new spec
2. Compare with existing files
3. Show diff (added/removed endpoints and models)
4. Ask if you want to apply changes
5. Update only the generated sections (preserves your custom code)

### 3. Manual generation (without OpenAPI spec)

```
User: "I need a REST API network layer for my iOS app"
```

The skill will ask:
- Do you have an OpenAPI/Swagger spec?
- If no: project name, URLs, endpoints etc.

## Output files

The skill generates the following files:

```
{ProjectName}/
├── {ProjectName}API.swift          # Protocol definition
├── NetworkService.swift             # Real implementation
├── MockNetworkService.swift         # Mock for tests
├── Helpers.swift                    # Extensions, JWT, TokenStore
└── Models/                          # (only if OpenAPI has schemas)
    ├── User.swift
    ├── Production.swift
    └── ...
```

## OpenAPI → Swift mapping

| OpenAPI Type | Swift Type |
|--------------|------------|
| `string` | `String` |
| `integer` | `Int` |
| `number` | `Double` |
| `boolean` | `Bool` |
| `array` | `[Type]` |
| `object` | nested struct |
| `string(date-time)` | `Date` |
| `string(uuid)` | `UUID` |
| nullable | `Type?` |

## Example: From OpenAPI to Swift

**OpenAPI spec:**
```yaml
paths:
  /v1/users/{id}:
    get:
      operationId: getUser
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'

components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
          format: uuid
        name:
          type: string
        email:
          type: string
        createdAt:
          type: string
          format: date-time
```

**Generated Swift code:**

`ApiComponent` enum gets:
```swift
case users
```

`Models/User.swift`:
```swift
struct User: Codable {
    let id: UUID
    let name: String
    let email: String
    let createdAt: Date
}
```

Usage in app:
```swift
let api: NetworkService = NetworkService()
let user: User = try await api.endPoint(method: .GET, .v1, .users, values: userId)
```

## Update workflow

When updating:

1. The skill finds existing `NetworkService.swift`
2. Reads the `ApiComponent` enum between `// MARK: - Generated Endpoints` markers
3. Compares with new OpenAPI spec
4. Shows diff like:
   ```
   Added endpoints:
   + case notifications
   + case settings

   Removed endpoints:
   - case legacyMessages

   Modified models:
   User: added 'avatarUrl: String?'
   Production: removed 'deprecatedField'
   ```
5. Asks: "Apply these changes?"
6. Updates only generated sections (preserves custom code)

## Tips

1. **Always use OpenAPI specs when possible** - ensures your Swift client always matches backend
2. **Commit before updating** - so you can easily see diff and rollback if needed
3. **Custom endpoints**: Add them OUTSIDE the generated markers, so they won't be overwritten
4. **Test after update**: Mock service is also updated automatically

## Example of custom code that's preserved

```swift
enum ApiComponent: String {
    // MARK: - Generated Endpoints
    case users, productions
    // MARK: - End Generated Endpoints

    // Your custom endpoints (preserved during updates):
    case myCustomEndpoint
}
```

## Dependencies

This skill generates code that requires the following Swift Package:

### Auth0 JWTDecode

For JWT token decoding and expiration checking.

**Installation in Xcode:**
1. File → Add Package Dependencies
2. Enter: `https://github.com/auth0/JWTDecode.swift`
3. Version: 3.0.0 or later

**Installation via Package.swift:**
```swift
dependencies: [
    .package(url: "https://github.com/auth0/JWTDecode.swift", from: "3.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "JWTDecode", package: "JWTDecode.swift")
        ]
    )
]
```

**Important**: Remember to add this dependency after generating the files!

## Support

The skill supports:
- OpenAPI 3.0.x (Scalar)
- OpenAPI 2.0 (Swagger)
- JSON and YAML format
- Both URL and local file path
