# cossistant-admin-swift

`cossistant-admin-swift` is the shared Swift SDK for the Cossistant admin backend.

It provides:

- typed backend domain models
- a first-class `CossistantAdminClient` entrypoint
- REST endpoint access for bootstrap, conversations, contacts, knowledge, uploads, and visitors
- realtime connection support for backend events

It intentionally does not include:

- `SwiftUI`, `AppKit`, or app navigation/state
- local host-app persistence such as `UserDefaults` or Keychain profile management
- OpenAI or Google Translate integrations

## Package Layout

- `Sources/CossistantAdmin/Client/` for the SDK entrypoint and endpoint clients
- `Sources/CossistantAdmin/Domain/` for shared backend models
- `Sources/CossistantAdmin/Realtime/` for realtime connection support
- `Sources/CossistantAdmin/Diagnostics/` and `Support/` for backend-facing helpers

## Usage

```swift
import CossistantAdmin

let client = CossistantAdminClient(
  configuration: DashboardConfiguration(
    baseURL: URL(string: "https://api.cossistant.com")!,
    privateAPIKey: "<private-api-key>"
  )
)

let inbox = try await client.conversations.fetchInbox(limit: 50)
let websites = try await client.bootstrap.fetchWebsites()
```

## Development

- Build: `swift build`
- Test compile in an app host: add the package via Swift Package Manager and import `CossistantAdmin`

This package is intended to be consumed by:

- `cossistant-admin-mac`
- `cossistant-admin-ios`
