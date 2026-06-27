---
name: swift-KeyChainWrap
description: Implements secure Keychain storage for Apple platforms using KeychainHelper and TokenStore with customizable token types (JWT, refresh, userId, etc). Use when user needs secure credential storage in Swift/SwiftUI apps.
---

# Swift Keychain Wrapper Implementation

This skill provides a secure, type-safe way to store sensitive data (tokens, credentials, secrets) in the Keychain on Apple platforms (iOS, macOS, watchOS, tvOS, visionOS).

## When to Use This Skill

Use this skill when the user requests:
- Secure storage for authentication tokens (JWT, refresh tokens, access tokens)
- Keychain implementation for storing credentials
- Type-safe wrapper for Keychain access
- Token management in a Swift/SwiftUI app
- Secure storage for user IDs, provider tokens, or other secrets

## What This Skill Provides

Two template files that work together:

1. **KeychainHelper.swift** - Low-level Keychain operations (save, read, delete)
2. **TokenStore.swift** - High-level token management with TokenType enum

## Default Token Types

The template includes these token types:
- `userId` - User identifier
- `access` - Access/JWT token
- `refresh` - Refresh token
- `provider` - OAuth provider token

## Implementation Instructions

### 1. Basic Implementation

When user requests Keychain storage:
1. Copy both template files to the project
2. Place in appropriate directory (e.g., `Services/`, `Helpers/`, or `Storage/`)
3. Ensure files are added to the correct target

### 2. Adding New Token Types

When user requests additional token types:
1. Add new case to the `TokenType` enum in TokenStore.swift
2. If needed, update `clearAll()` method to include the new type
3. Example:
   ```swift
   enum TokenType: String {
       case userId
       case access
       case refresh
       case provider
       case apiKey        // New type
       case deviceToken   // New type
   }
   ```

### 3. Removing Token Types

When user wants to remove a token type:
1. Remove the case from `TokenType` enum
2. Remove corresponding delete call from `clearAll()` method (if present)
3. Ensure no other code references the removed type

### 4. Customizing Token Types

If user wants different token types entirely:
1. Replace the entire `TokenType` enum with requested types
2. Update `clearAll()` method to match new types
3. Keep the same pattern: `case typeName` format

### 5. Modifying Existing Implementation

If user already has TokenStore/KeychainHelper and wants to:
- **Add types**: Add new cases to existing TokenType enum, update clearAll()
- **Remove types**: Remove case from enum, remove from clearAll()
- **Replace types**: Update TokenType enum with new cases, update clearAll() accordingly

## Usage Example

Show user how to use the implementation:

```swift
// Save tokens
TokenStore.save("eyJhbGc...", type: .access)
TokenStore.save("user123", type: .userId)

// Read tokens
if let accessToken = TokenStore.read(type: .access) {
    // Use token for API calls
}

// Clear all tokens (logout)
TokenStore.clearAll()
```

## Important Notes

- KeychainHelper uses `kSecAttrAccessibleAfterFirstUnlock` for device restart compatibility
- All operations are synchronous - consider wrapping in Task for async contexts
- TokenStore uses static methods - no instance needed
- Keychain data persists across app uninstalls on iOS (user must manually delete)
- Use `clearAll()` for logout functionality

## File Organization

Follow SwiftUI conventions:
- Place in dedicated folder: `Services/Keychain/` or `Helpers/Security/`
- Keep both files together
- Consider adding unit tests for Keychain operations

## Testing Considerations

Suggest to user:
- Unit tests should use separate keychain keys (e.g., prefix with "test_")
- Clear test data in tearDown
- Keychain access requires proper entitlements in test targets
