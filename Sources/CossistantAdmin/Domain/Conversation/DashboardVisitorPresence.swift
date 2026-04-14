import Foundation

public struct DashboardVisitorPresence: Equatable, Sendable {
  public enum State: String, Sendable {
    case active
    case inactive
  }

  public let visitorId: String
  public let state: State
  public let lastSeenAt: String?

  public init(
    visitorId: String,
    state: State,
    lastSeenAt: String? = nil
  ) {
    self.visitorId = visitorId
    self.state = state
    self.lastSeenAt = lastSeenAt
  }

  public var isActive: Bool {
    state == .active
  }
}
