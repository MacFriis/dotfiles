## Personal Context

**Knee surgery recovery (May 2026):** User had a partial knee replacement on 2026-05-06. Still on reduced capacity / "reserve power" while recovering — recovery from a knee prosthesis takes weeks to months.

**How to apply:**
- Keep sessions focused on one thing at a time
- Don't stack parallel workstreams or pile on follow-ups
- If user mentions being tired or beat, default to lighter work (quick fixes, planning) over heavy implementation
- Let the user steer pace — don't push

---

## Infrastructure

**Infrastructure project:** `/Users/perfriis/Developer/FriisConsult/infrastructure/`

Always check this repo before working on infrastructure, deployments, NGINX/reverse proxy configs, server architecture, CI/CD workflow templates, or directory layouts. Key files: `inventory.yaml`, `inventory.md`, `deployment-standards.md`.

---

## Project Management

### Scrum/Kanban Workflow
Track all work in **Markdown files under `docs/`** managed via Claude/AI assistance. GitHub Issues/Projects are **not** used for project tracking.

**Source-of-truth files per project:**
- `docs/MILESTONES.md` — release milestones, what's shipped, current, planned
- `docs/sprints/CURRENT.md` — live status of current sprint/work
- `docs/features/*.md` — feature specs (epics, user stories, acceptance criteria)
- `docs/backlog/*.md` — consolidated backlogs by platform (iOS, Android, Backend, etc.)
- `docs/features/ROADMAP.md` — feature prioritization and phases

**Workflow:**
1. Write feature specs in `docs/features/` with user stories and acceptance criteria
2. Break work into tasks when starting — use Claude's task tool for session-level tracking
3. Update `docs/sprints/CURRENT.md` when priorities or status change
4. Move shipped items to the "Shipped" section in `MILESTONES.md`
5. Write descriptive commit messages (no `Fixes #123` references needed)

---

## Development Environment

### Package Managers
- **Do NOT use Homebrew** - I do not have brew installed and do not want it on my machine
- For macOS tools, prefer direct downloads, .pkg installers, or App Store when available
- For CLI tools, use official installation methods (curl scripts, direct binaries, etc.)

### Multi-Device Deployment Script
`~/.local/bin/run-on-devices` builds an iOS/visionOS app once and installs on all connected physical devices in parallel. See the `deploy-devices` skill for full usage.

---

## Standard Project Structure

### Monorepo by Default
All projects use a **monorepo** unless there are specific reasons not to (e.g., completely separate teams, different deployment lifecycles).

**Standard monorepo layout:**
```
project-root/
├── ProjectName-api/          # .NET backend (API, workers)
├── frontend/                  # Web frontend (TypeScript/Vite)
├── ProjectName/              # Native Apple app (if applicable)
├── docs/                      # Project documentation
│   ├── architecture/          # System architecture, decisions
│   ├── planning/              # Roadmaps, sprint plans
│   ├── features/              # Feature specs, user stories
│   ├── business-model/        # Business model, pricing, strategy
│   └── ...                    # Other relevant categories
├── .github/workflows/         # CI/CD pipelines
├── deploy/                    # Shared deployment configs
└── CLAUDE.md                  # Project-level Claude instructions
```

### Documentation in `docs/`
Every project should have a `docs/` folder with structured documentation:
- **architecture/** — System design, ADRs, data flow diagrams
- **planning/** — Sprint plans, milestones, backlog prioritization
- **features/** — Feature specs with epics, user stories, acceptance criteria
- **business-model/** — Revenue model, pricing strategy, market analysis
- Additional folders as needed per project

### Project Management Methodology
Run a **Scrum/Kanban hybrid**, tracked in Markdown files under `docs/`:
- **Backlog** — Prioritized list in `docs/backlog/*.md` (split by platform)
- **Epics** — Large features documented in `docs/features/*.md`
- **User Stories** — "As a [role], I want [feature] so that [benefit]" — inside feature specs
- **Tasks** — Concrete implementation steps tracked via Claude's task tool during sessions
- **Current status** — `docs/sprints/CURRENT.md` is the live source of truth
- **Releases** — `docs/MILESTONES.md` tracks shipped / current / planned versions

## Preferred Language / Frameworks

### Backend - API & Workers
- **C# .NET 10** (latest, upgrade when stable)
- **Entity Framework Core 9** — Pomelo.EntityFrameworkCore.MySql doesn't yet support EF Core 10 with MariaDB
- **MariaDB** database
- **Scalar** for API documentation
- **Hangfire** for background jobs
- **SignalR** for real-time communication

### Frontend - Apple Device
- iOS, visionOS, macOS, tvOS, watchOS
- Native Swift, SwiftUI
- JSON files or SwiftData depending on the feature
- **CI/CD: Xcode Cloud** — NOT GitHub Actions for Apple platform builds/distribution

#### TestFlight "What to Test" Notes (Xcode Cloud Pattern)
Generate structured test notes automatically via `ci_scripts/ci_post_xcodebuild.sh`:
1. Get commits since last tag (filtered to app-relevant paths)
2. Group by type (features, fixes, UI changes)
3. Generate human-readable test notes
4. Set via App Store Connect API as "What to Test" on the TestFlight build

Requires App Store Connect API key configured in Xcode Cloud environment variables. Same script can be run locally to preview notes before pushing.

### Embedded / IoT
- **PlatformIO** (not Arduino IDE) for all embedded projects
- Arduino ecosystem (Nano 33 BLE, ESP32, etc.)
- **u-blox** for GNSS modules (ZED-F9P for RTK precision)
- BLE for communication with Apple devices
- NMEA for GNSS data, RTCM3 for RTK corrections

### Frontend - Web
- **TypeScript** with **Vite** build tool
- **React** as default (evaluate alternatives per project)
- **Tailwind CSS** for styling
- **Lucide Icons** (`lucide-react` / `lucide-vue`) — modern, tree-shakeable replacement for Font Awesome

### Other
- Always use the best tool/framework for the task — don't use a hammer to put in screws
- All code and comments must be in English
- All user interfaces start in English, with later localization

## Testing
- Always suggest unit tests
- Always suggest UI tests for client apps

## Git Workflow

### Branching Strategy (Gitflow)
Follow **Gitflow** branching model:

- `main` — Production-ready code, always deployable
- `develop` — Integration branch for features
- `feature/{description}` — New features, branched from `develop`
- `fix/{description}` — Bug fixes
- `hotfix/{description}` — Urgent production fixes, branched from `main`
- `release/{version}` — Release preparation, branched from `develop`

**Workflow:**
1. Create `feature/` branch from `develop`
2. Work on feature, commit with issue references (`Fixes #123`)
3. Create PR to `develop`
4. CI must pass before merge
5. Merge `develop` → `release/` → `main` for releases

### Pull Request Workflow
- **CI is required** — all PRs must have passing CI checks where applicable
- **No reviewer requirement** — most projects are solo (me + Claude/Codex)
- Keep PRs focused and reasonably sized
- Use PR description to explain the "why"

## Repo / Deployment
- Default to monorepo (see Standard Project Structure above)
- Always create deployment scripts, ready for self-hosted CI runners
- Follow zero-downtime deployment with atomic symlinks (see CI/CD section)
- **Docker Compose** for enterprise/on-premise deployment — every project with a backend should have a `docker-compose.yml` that spins up the full stack (API, workers, database, message broker) with a single `docker compose up`

## CI/CD with GitHub Actions (Self-Hosted Runners)

All backend/web projects deploy via GitHub Actions to self-hosted Linux runners with zero-downtime symlink swaps under `/srv/{project}/`. Use **project labels** in `runs-on`, not server names. See the `cicd-selfhosted` skill for full patterns (runner labels, folder structure, systemd template, required deploy files, new-server checklist).

## Logging

### Apple (iOS / macOS / visionOS)
**Use OSLog** with structured logging via `Logger`:
```swift
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "\(NetworkService.self)")

// Usage
logger.info("Fetching crews")
logger.error("Failed to load data: \(error.localizedDescription)")
logger.debug("Response: \(response)")
```

### .NET
**Use built-in `ILogger<T>`** via dependency injection:
```csharp
public class CrewService : ICrewService
{
    private readonly ILogger<CrewService> _logger;

    public CrewService(ILogger<CrewService> logger)
    {
        _logger = logger;
    }
}
```

### JavaScript / Kotlin
No specific preference — use standard conventions for the platform.

---

## Authentication

### Standard Approach
- **JWT** for API authentication
- **Sign in with Apple (SIWA)** as primary social login
- **Sign in with Google** as secondary social login
- Follow current platform best practices for token storage and refresh

---

## C# / .NET Conventions

### API Versioning
**Use URL-based versioning** with `/api/v{n}/` prefix:

```csharp
// ✅ CORRECT
[ApiController]
[Route("api/v1/[controller]")]
public class CrewsController : ControllerBase { }

// Future version
[ApiController]
[Route("api/v2/[controller]")]
public class CrewsV2Controller : ControllerBase { }
```

### Async Method Naming
**Do NOT include "Async" suffix in method names**, even for async methods returning Task/Task<T>.

**Why:**
- Cleaner, more concise method names
- Async is an implementation detail, not part of the contract
- Modern C# convention moving away from Async suffix

**Examples:**
```csharp
// ✅ CORRECT
public interface IContactUsService
{
    Task<ContactUs> CreateContactRequest(Guid userId, string email, string message);
    Task<List<ContactUs>> GetAllContactRequests(DateTimeOffset? since = null);
}

// ❌ INCORRECT
public interface IContactUsService
{
    Task<ContactUs> CreateContactRequestAsync(Guid userId, string email, string message);
    Task<List<ContactUs>> GetAllContactRequestsAsync(DateTimeOffset? since = null);
}
```

**Exception:** Only use Async suffix when you need to distinguish between sync and async versions of the same method.

### Nullable Reference Types
**Always enable nullable reference types** in all C# projects.

**Guidelines:**
- Use `?` for nullable reference types explicitly
- Avoid `null!` suppressions unless absolutely necessary
- Use nullable annotations in method signatures
- Return `Task<T?>` when result might be null

**Example:**
```csharp
// ✅ CORRECT
public async Task<User?> GetUser(Guid id)
{
    return await _context.Users.FindAsync(id);
}

// ❌ INCORRECT
public async Task<User> GetUser(Guid id)
{
    return await _context.Users.FindAsync(id)!; // Suppression hides potential null
}
```

### Dependency Injection
**Use constructor injection** for all dependencies.

**Guidelines:**
- Register services with appropriate lifetime (Transient, Scoped, Singleton)
- Use interfaces for abstraction
- Avoid service locator pattern
- Keep constructors simple (assignment only)

**Example:**
```csharp
// ✅ CORRECT
public class ContactUsService : IContactUsService
{
    private readonly ApplicationDbContext _context;
    private readonly IEmailService _emailService;

    public ContactUsService(ApplicationDbContext context, IEmailService emailService)
    {
        _context = context;
        _emailService = emailService;
    }
}

// Registration in Program.cs
builder.Services.AddScoped<IContactUsService, ContactUsService>();
builder.Services.AddTransient<IEmailService, EmailService>();
```

### API Endpoint Naming
**Use RESTful conventions** with lowercase and hyphens.

**Guidelines:**
- Use plural nouns for resources: `/api/users`, `/api/contact-requests`
- Use HTTP verbs appropriately (GET, POST, PUT, DELETE, PATCH)
- Use sub-resources for relationships: `/api/users/{id}/orders`
- Avoid verbs in URLs (use HTTP methods instead)

**Example:**
```csharp
// ✅ CORRECT
[HttpGet("contact-requests")]
[HttpGet("contact-requests/{id}")]
[HttpPost("contact-requests")]
[HttpPut("contact-requests/{id}")]
[HttpDelete("contact-requests/{id}")]

// ❌ INCORRECT
[HttpGet("GetContactRequests")]
[HttpPost("CreateContactRequest")]
```

### Entity Framework Conventions
**Guidelines:**
- Use singular entity names: `User`, `Order`, `ContactRequest`
- Use plural table names: `Users`, `Orders`, `ContactRequests`
- Always use migrations for schema changes
- Use `DbContext` with scoped lifetime
- Prefer explicit configuration over conventions for complex scenarios

**Example:**
```csharp
public class ApplicationDbContext : DbContext
{
    public DbSet<User> Users { get; set; }
    public DbSet<ContactRequest> ContactRequests { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>(entity =>
        {
            entity.ToTable("Users");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Email).IsRequired().HasMaxLength(256);
        });
    }
}
```

### JSON Serialization - Date/Time Handling

**IMPORTANT: Always use ISO8601 format for dates in JSON APIs.**

**Why ISO8601:**
- ✅ Standard format across platforms (JavaScript, Swift, Python, etc.)
- ✅ Human-readable: `"2024-11-14T15:30:00Z"`
- ✅ Timezone-aware
- ❌ Do NOT use Apple epoch (seconds since 2001-01-01) - not cross-platform

**Critical .NET Issue: Default precision is too high**
- .NET's default JsonSerializer writes 7 decimal places: `"2024-11-14T15:30:00.1234567Z"`
- Apple's JSONDecoder typically only handles 3 decimal places (milliseconds)
- **This causes parsing errors in Swift clients**

**Solution: Configure JsonSerializerOptions globally**

```csharp
// In Program.cs or Startup.cs
builder.Services.ConfigureHttpJsonOptions(options =>
{
    // Use ISO8601 with 3 decimal places (milliseconds)
    options.SerializerOptions.Converters.Add(
        new JsonDateTimeConverter() // Custom converter that limits precision
    );
});

// Or use custom JsonSerializerOptions
var jsonOptions = new JsonSerializerOptions
{
    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
    Converters = { new JsonStringEnumConverter() }
};

// Custom converter to limit DateTime precision
public class JsonDateTimeConverter : JsonConverter<DateTime>
{
    public override DateTime Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        return DateTime.Parse(reader.GetString()!);
    }

    public override void Write(Utf8JsonWriter writer, DateTime value, JsonSerializerOptions options)
    {
        // Format with 3 decimal places (milliseconds) only
        writer.WriteStringValue(value.ToString("yyyy-MM-ddTHH:mm:ss.fffZ"));
    }
}
```

**Swift Client Configuration:**
```swift
// In NetworkService.swift or similar
extension JSONDecoder {
    static let api: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

extension JSONEncoder {
    static let api: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}

// Usage: JSONDecoder.api.decode(T.self, from: data)
```

**Testing Date Serialization:**
```csharp
// Test that your API returns ISO8601 with correct precision
var video = new Video
{
    CreatedAt = DateTime.UtcNow
};
var json = JsonSerializer.Serialize(video, jsonOptions);
// Should output: {"createdAt":"2024-11-14T15:30:00.123Z"}
// NOT: {"createdAt":"2024-11-14T15:30:00.1234567Z"}
```

## Multi-Platform Apple Development (iOS / macOS / visionOS)

**CRITICAL: Minimize `#if os()` conditionals.** Use Xcode Target Membership for platform separation instead.

### Architecture: Separate Files Per Platform

When a view or component differs significantly between platforms, create **separate files per platform** with the same type name:

```
Features/
  ├── Settings/
  │   ├── SettingsView.swift          # Shared (if identical)
  │   ├── SettingsView iOS.swift      # iOS-specific implementation
  │   └── SettingsView macOS.swift    # macOS-specific implementation
  └── Production/
      ├── QRScannerView iOS.swift     # iOS camera-based scanner
      └── QRScannerView macOS.swift   # macOS alternative (file picker, paste, etc.)
```

**How it works:**
1. Both files define the same `struct SettingsView: View` (same type name)
2. Use **Xcode Target Membership** to assign each file to its platform target
3. The compiler sees only one definition per target — no conflicts, no conditionals

**When to use `#if os()`:**
- Small, inline differences (1-3 lines) within an otherwise shared view
- Platform availability checks for specific APIs in shared code
- **Never** for large blocks of platform-specific UI

### Platform API Extensions (Bridge Pattern)

When an API exists on one platform but not another (e.g., `Color.systemGreen` is UIKit-only), create **extensions on macOS** to provide the same API:

```swift
// Color+macOS.swift (macOS target only)
import AppKit

extension Color {
    static var systemGreen: Color { Color(nsColor: .systemGreen) }
    static var systemBlue: Color { Color(nsColor: .systemBlue) }
}
```

```swift
// Color+iOS.swift (iOS target only)
import UIKit

extension Color {
    static var systemGreen: Color { Color(uiColor: .systemGreen) }
}
```

**Benefits:**
- Views use `Color.systemGreen` everywhere — no `#if os()` needed
- Platform differences are isolated in extension files
- Same pattern works for any platform-specific API

### Rules
1. **Prefer Target Membership over `#if os()`** — always
2. **Same type name, different files** — compiler resolves via target membership
3. **Bridge missing APIs with extensions** — so shared code compiles on all platforms
4. **Refactor existing `#if os()` blocks** — when touching files with large conditional blocks, extract into separate platform files

---

## SwiftUI View Organization

**Always separate views into individual files.** Each view should have its own file following this structure:
```
Views/
  ├── ListViews/
  │   └── CrewListView.swift
  ├── DetailViews/
  │   └── CrewDetailView.swift
  └── Components/
      └── CrewRowView.swift
```

**Why:**
- Single Responsibility Principle - each file has one purpose
- Better code navigation and maintainability
- Easier testing and reusability
- Cleaner git history and fewer merge conflicts

**Exception:** Only combine views in the same file when:
- Creating temporary preview helpers
- The child view is truly private and very simple (< 10 lines)
- Rapid prototyping that will be refactored later

**Example structure:**
- `CrewListView.swift` - List/collection view
- `CrewDetailView.swift` - Detail view for single item
- `CrewRowView.swift` - Reusable row component (if needed)

When in doubt, create a separate file.

### Component Reusability

**Always create reusable components when the same UI pattern appears multiple times.**

**Guidelines:**
- Extract common UI patterns into separate, parameterized components
- Ensure consistent UI/UX across the app by using the same components
- Components should be configurable through parameters, not duplicated code
- Place reusable components in appropriate directories (e.g., `Components/`)

**Example:**
```swift
// ✅ CORRECT - Reusable component
struct InlineQRScannerView: View {
    let title: String
    let scannerTitle: String
    let logPrefix: String
    @Binding var isExpanded: Bool

    var body: some View {
        // Shared implementation
    }
}

// Usage in multiple views
InlineQRScannerView(
    title: "Scan QR code",
    scannerTitle: "Scan production QR code",
    logPrefix: "[ProductionWelcome]",
    isExpanded: $showingQRScanner
)

// ❌ INCORRECT - Duplicated code
// Copying the same QR scanner UI into ProductionWelcomeView and SettingsView
```

**Benefits:**
- Single source of truth for UI patterns
- Consistent behavior and appearance
- Easier to maintain and update
- Reduces code duplication
- Ensures uniform UX across the app

### State Management
**Use modern Swift Observation framework** (`@Observable` macro, iOS 17+).

**IMPORTANT: Do NOT use old Combine-based patterns:**
- ~~`ObservableObject`~~ → use `@Observable`
- ~~`@Published`~~ → just use `var` in `@Observable` class
- ~~`@StateObject`~~ → use `@State` for view-local `@Observable` instances
- ~~`@ObservedObject`~~ → use `@Environment` for injected services
- ~~`@EnvironmentObject`~~ → use `@Environment` with custom `EnvironmentKey`

**Guidelines:**
- `@State` - For simple view-local state (primitives, or view-owned `@Observable`)
- `@Environment` - For shared services/controllers/sessions injected via `EnvironmentKey`
- `@Binding` - For two-way communication with parent views
- `@Observable` - For all service/controller/session classes
- `SwiftData` (`@Model`) - For persisted data

**Example:**
```swift
// ✅ CORRECT - @Observable service
@Observable final class CrewService {
    var crews: [Crew] = []
    var isLoading = false

    @ObservationIgnored
    private let api: APIClient

    func fetchCrews() async throws { ... }
}

// ✅ CORRECT - Injected via Environment
struct CrewListView: View {
    @Environment(\.crewService) private var crewService

    var body: some View {
        List(crewService.crews) { crew in
            CrewRowView(crew: crew)
        }
    }
}

// ✅ CORRECT - View-local @Observable
struct CrewEditView: View {
    @State private var formState = CrewFormState()

    var body: some View {
        Form {
            TextField("Name", text: $formState.name)
        }
    }
}

// ✅ CORRECT - Child view receives binding
struct ToggleRow: View {
    @Binding var isEnabled: Bool

    var body: some View {
        Toggle("Enabled", isOn: $isEnabled)
    }
}
```

### Naming Conventions
**Follow Swift API Design Guidelines**.

**Views:**
- Descriptive names ending with "View": `CrewListView`, `SettingsView`
- Component views: `CrewRowView`, `LoadingIndicator`
- Container views: `CrewDetailContainer`, `NavigationContainer`

**Properties:**
- `@State` properties: `private var isShowingSheet = false`
- `@Environment` properties: `@Environment(\.myService) private var myService`
- Bindings: descriptive names matching their purpose

**Methods:**
- Action handlers: `handleSaveButtonTapped()`, `handleDismiss()`
- Computed properties for complex views: `var headerSection: some View`

### Preview Organization
**Always include previews** with multiple states.

**Example:**
```swift
#Preview("Default") {
    CrewListView()
}

#Preview("Empty State") {
    CrewListView(viewModel: CrewListViewModel(crews: []))
}

#Preview("Loading") {
    CrewListView(viewModel: CrewListViewModel(isLoading: true))
}

#Preview("Dark Mode") {
    CrewListView()
        .preferredColorScheme(.dark)
}
```

### SwiftUI Environment & Dependency Injection

**Use EnvironmentKey for shared dependencies** instead of singletons or direct injection.

**Pattern:**
```swift
// 1. Define the EnvironmentKey
struct MyServiceKey: EnvironmentKey {
    static let defaultValue: MyServiceProtocol = DefaultMyService()
}

extension EnvironmentValues {
    var myService: MyServiceProtocol {
        get { self[MyServiceKey.self] }
        set { self[MyServiceKey.self] = newValue }
    }
}

// 2. Use in Views
struct MyView: View {
    @Environment(\.myService) var service

    var body: some View { ... }
}

// 3. Inject in App/Parent
ContentView()
    .environment(\.myService, ProductionMyService())
```

**Benefits:**
- Testable: Inject mock services in previews/tests
- Decoupled: Views don't know concrete implementations
- SwiftUI-native: Works with view lifecycle

### Preview Traits with PreviewModifier

**Use PreviewModifier for complex preview setups** that require shared state or multiple environment values.

**Pattern:**
```swift
// 1. Create PreviewModifier
struct AppStatePreviewModifier: PreviewModifier {
    typealias Context = AppState

    static func makeSharedContext() async throws -> Context {
        AppState.preview  // Return configured preview state
    }

    func body(content: Content, context: Context) -> some View {
        content
            .environment(\.appState, context)
            .environment(\.apiService, MockAPIService())
    }
}

// 2. Register as PreviewTrait
extension PreviewTrait where T == Preview.ViewTraits {
    static var appState: Self = modifier(AppStatePreviewModifier())
}

// 3. Use in Previews
#Preview("Default", traits: .appState) {
    MyView()
}
```

**Guidelines:**
- Create traits for each user role/state (admin, member, guest)
- Traits should inject ALL required environment values
- Use static preview data for consistent, reproducible previews
- Traits must work for both Previews AND UI Tests

### Preview Data Organization

**Keep preview/test data in extensions:**
```swift
extension User {
    static let previewAdmin = User(id: .init(), role: .admin, ...)
    static let previewMember = User(id: .init(), role: .member, ...)
}

extension [User] {
    static let preview: [User] = [.previewAdmin, .previewMember]
}
```

**Requirements:**
- Use deterministic UUIDs for stable previews
- Cover all user roles and authentication states
- Include edge cases (empty lists, error states)

## User Experience (UX) Principles

**UX is a critical priority.** Every feature and interaction must be intuitive and easy to navigate.

### Core UX Guidelines:

**Navigation:**
- Keep navigation depth shallow (max 2-3 taps to any feature)
- Use standard iOS navigation patterns (NavigationStack, tabs, sheets)
- Always provide clear back buttons and escape routes
- Ensure users know where they are in the app hierarchy

**Interaction Design:**
- Use familiar iOS gestures (swipe, tap, long-press)
- Provide immediate visual feedback for all actions
- Loading states should be clear with progress indicators
- Error messages must be actionable ("Try again" vs "Error occurred")

**Visual Clarity:**
- Important actions should be prominent and easy to tap
- Use SF Symbols for consistency with iOS ecosystem
- Maintain proper spacing and tap target sizes (min 44x44pt)
- Group related items logically

**Performance:**
- Keep UI responsive - no blocking operations on main thread
- Show skeleton/placeholder content while loading
- Optimize list scrolling performance
- Cache data appropriately to minimize loading times

**Accessibility:**
- All interactive elements must have accessibility labels
- Support Dynamic Type for text scaling
- Ensure sufficient color contrast
- Test with VoiceOver enabled

### Before Implementing Any Feature, Ask:
1. Can the user complete this task in the fewest steps possible?
2. Will the user understand what to do without instructions?
3. Does this follow iOS Human Interface Guidelines?
4. Is there immediate feedback for the user's action?

**When in doubt, choose the simpler, more obvious solution.**

## TypeScript / React Conventions

Follow current, leading-edge community standards (not bleeding-edge experimental). Verify with up-to-date docs when in doubt; conventions move fast in this ecosystem.

- **TypeScript:** strict mode on, no `any`, prefer inference, use utility types (`Partial`, `Pick`, `Omit`).
- **Components:** one component per file, PascalCase filename matching component name. Hooks: camelCase with `use` prefix.
- **State:** `useState`/`useEffect` for local, Context for shared, Zustand/Jotai for complex global state.
- **CSS:** Tailwind is the default — verify it's still the goto when starting a new project. No inline styles when a utility class works.
- **Icons:** Lucide (`lucide-react`/`lucide-vue`). **Not** FontAwesome (outdated, not tree-shakeable).

## Database Conventions

Default to **MariaDB** with **EF Core code-first** — entity classes drive schema, migrations are generated from them. Don't write CREATE TABLE statements by hand.

- Use standard EF Core conventions (singular entity names → plural tables, navigation properties, data annotations or fluent config).
- Always use migrations for schema changes — one migration per logical change, meaningful names, never modify after deployment.
- Snake case at the DB level is fine if EF Core is configured for it, but follow whatever the project already uses.