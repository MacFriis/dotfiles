# Swift REST API Network Layer Generator

Generate a complete Swift REST API network layer with protocol, mock implementation, and real implementation using URLSession.

**Supports OpenAPI/Swagger/Scalar** - Can read OpenAPI specs (v2/v3) to automatically generate endpoints, models, and keep them in sync with backend changes.

## Pattern

This skill generates four core files plus optional model files:

1. **{ProjectName}API.swift** (Protocol) - Defines the API interface
2. **MockNetworkService.swift** - Mock implementation for testing
3. **NetworkService.swift** - Real implementation using the NetworkService Template  with:
   - JWT authentication with auto-refresh
   - Token management via TokenStore
   - Comprehensive header management
   - Error handling with typed errors
   - Logger integration
   - Environment-based URL configuration (DEBUG/BETA/PRODUCTION)
4. **Helpers.swift** - Supporting code (Encodable.json, JWT decoding, TokenStore, etc.)
5. **Models/{ModelName}.swift** - Generated from OpenAPI schemas (optional)

## Infrastructure Features

- **Token Management**: Automatic JWT token refresh when expired
- **Headers**: Built-in support for API key, app metadata, language, since-date optimization
- **Error Handling**: Typed errors with ApiError enum
- **Logging**: OSLog integration for debugging
- **Testing**: Mock service with call recording for verification
- **Environments**: Support for DEBUG, BETA, and PRODUCTION configurations
- **OpenAPI Integration**: Parse OpenAPI/Swagger/Scalar specs to generate endpoints and models

## Usage Modes

### Mode 1: Generate from OpenAPI Spec (Recommended)

When user provides an OpenAPI spec (URL or file path):

1. **Fetch/Read the OpenAPI spec** (JSON or YAML)
2. **Extract information**:
   - Base URLs from `servers` section
   - Endpoints from `paths` section → generate `ApiComponent` enum cases
   - Request/Response models from `components.schemas` → generate Swift structs
   - Authentication schemes from `security` section
   - API info (title, version) for naming

3. **Ask user**:
   - "Found API: {title}. Use '{title}' as project name?" (default: yes)
   - "Found {N} endpoints. Generate all or select specific ones?" (default: all)
   - "Generate response models from schemas?" (default: yes)
   - Where to save files? (default: current directory or specific folder)

4. **Generate files**:
   - Replace `{{PROJECT_NAME}}` with API title or user's choice
   - Replace `{{BASE_URL_*}}` from servers section
   - Replace `{{API_KEY}}` from security schemes (if exists)
   - Generate `{{ADDITIONAL_COMPONENTS}}` from paths
   - Create Model files for each schema

5. **For updates**: Compare existing files with new spec:
   - Show diff of added/removed/changed endpoints
   - Show diff of model changes
   - Ask: "Apply these changes?" before updating

### Mode 2: Manual Generation (Legacy)

When user doesn't have OpenAPI spec, ask for:

1. **Project name** (e.g., "CrewCast" → protocol becomes `CrewCastAPI`)
2. **Base URLs**:
   - Production URL
   - Beta URL (optional, defaults to production)
   - Debug URL (optional, defaults to production)
3. **API Key** (if needed for x-api-key header)
4. **Additional API components** beyond the default auth endpoints

## OpenAPI Parsing Rules

### Endpoint Generation (`ApiComponent` enum)

From OpenAPI `paths`, generate enum cases:

```yaml
paths:
  /v1/users:
    get: ...
  /v1/users/{id}:
    get: ...
  /v1/productions/{id}/join:
    post: ...
```

Generates:
```swift
enum ApiComponent: String {
    case v1
    case users, productions
    case join
    // ... auth cases (always included) ...
}
```

### Model Generation

From OpenAPI `components.schemas`, generate Swift structs:

```yaml
components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
        name:
          type: string
        email:
          type: string
```

Generates:
```swift
struct User: Codable {
    let id: String
    let name: String
    let email: String
}
```

### Type Mapping

OpenAPI → Swift:
- `string` → `String`
- `integer` → `Int`
- `number` → `Double`
- `boolean` → `Bool`
- `array` → `[Type]`
- `object` → nested struct or `[String: Any]`
- `string(date-time)` → `Date`
- `string(date-time)` → `Date` when humber using apple sec since 2001....
- `string(uuid)` → `UUID`
- nullable → `Type?`

## Examples

### Example 1: Generate from OpenAPI URL

User: "Create Swift API client from my Scalar spec: https://api.example.com/openapi.json"

Steps:
1. Fetch the OpenAPI spec from URL
2. Parse title (e.g., "MovieDB API")
3. Ask: "Found MovieDB API v2.1. Use 'MovieDB' as project name?"
4. Show: "Found 15 endpoints: GET /movies, POST /movies, etc."
5. Generate all 4 core files + model files
6. Save to user's project

### Example 2: Update existing API client

User: "Update my Swift API - backend has new endpoints"

Steps:
1. Ask: "Where's your OpenAPI spec?" (URL or file path)
2. Fetch/read the spec
3. Find existing NetworkService.swift and models
4. Compare ApiComponent enum cases (old vs new)
5. Show diff:
   ```
   Added endpoints:
   + case notifications
   + case settings

   Removed endpoints:
   - case legacyAuth

   Modified models:
   User: added field 'avatar: String?'
   ```
6. Ask: "Apply these changes?"
7. Update files accordingly

### Example 3: Manual generation (no OpenAPI)

User: "I need a REST API network layer for my app"

Ask:
1. Do you have an OpenAPI/Swagger/Scalar spec? (URL or file path)
2. If no: Fall back to manual mode
   - Project name?
   - Base URLs?
   - Endpoints? (user lists them)
   - Generate basic structure

## File Placeholders

Templates use these placeholders for substitution:
- `{{PROJECT_NAME}}` - The project/API name
- `{{BASE_URL_PRODUCTION}}` - Production API URL
- `{{BASE_URL_BETA}}` - Beta API URL
- `{{BASE_URL_DEBUG}}` - Debug/Development API URL
- `{{API_KEY}}` - The API key for x-api-key header
- `{{ADDITIONAL_COMPONENTS}}` - Additional ApiComponent enum cases (beyond default auth)

## Update Strategy

When updating existing files:
1. **Never overwrite user's custom code** - only update generated sections
2. **Use markers** to identify generated code blocks (e.g., `// MARK: - Generated Endpoints`)
3. **Preserve** user's custom ApiComponent cases, custom methods, custom headers
4. **Show diff** before applying changes
5. **Backup** old files before updating (optional, ask user)

## Dependencies

This skill generates code that requires the following Swift Package:

### Auth0 JWTDecode

**Repository**: https://github.com/auth0/JWTDecode.swift

Used for JWT token decoding and expiration checking in the authentication infrastructure.

**Installation**: When generating files, inform the user to add this dependency to their Xcode project:
1. File → Add Package Dependencies
2. Enter: `https://github.com/auth0/JWTDecode.swift`
3. Version: 3.0.0 or later

**Alternative**: Provide instructions for SPM Package.swift:
```swift
dependencies: [
    .package(url: "https://github.com/auth0/JWTDecode.swift", from: "3.0.0")
]
```

**NetworkService**: Always use the structure and generel implementation from the Templates

**MockNetworkService**: implement the calls from the protocol and return som preview/test data, that can be generated as json or as static preview var/let on the returning Struct


**Note**: Always remind the user about this dependency after generating files.
