# AGENTS.md

## Project Shape

- Swift package entry: `Package.swift`
- Public module: `CossistantAdmin`
- Main folders:
  - `Sources/CossistantAdmin/Client/` for the SDK entrypoint and endpoint groups
  - `Sources/CossistantAdmin/Domain/` for portable backend models
  - `Sources/CossistantAdmin/Realtime/` for realtime connection logic
  - `Sources/CossistantAdmin/Diagnostics/` and `Support/` for shared backend helpers

## Where To Start

- SDK root: `Sources/CossistantAdmin/Client/CossistantAdminClient.swift`
- Low-level transport: `Sources/CossistantAdmin/Client/CossistantAPIClient.swift`
- Conversations domain: `Sources/CossistantAdmin/Domain/Conversation/`
- Shared config/models: `Sources/CossistantAdmin/Domain/Shared/`
- Realtime: `Sources/CossistantAdmin/Realtime/CossistantRealtimeClient.swift`

## Working Rules

- Keep this package backend-only. Do not add `SwiftUI`, `AppKit`, `Observation`, prompts, or host-app persistence.
- Prefer host-agnostic APIs and typed models over app-specific convenience state.
- Keep `CossistantAdminClient` as the public app-facing entrypoint.
- Endpoint-specific logic belongs under `Client/`; product domain types belong under `Domain/`.
- OpenAI and Google Translate stay in embedding apps, not here.

## Skills And Tools

- Always use `swift-style` for Swift edits.
- Use `build-macos-apps:swiftpm-macos` for package build workflows when needed.
- Use `sosumi` for Apple API documentation instead of guessing.

## Verification

- Preferred build check: `swift build`
