import Foundation

public struct DashboardProfile: Codable, Equatable, Identifiable, Sendable {
  public let id: String
  public var name: String
  public var apiBaseURLString: String

  public init(
    id: String,
    name: String,
    apiBaseURLString: String
  ) {
    self.id = id
    self.name = name
    self.apiBaseURLString = apiBaseURLString
  }

  public var trimmedName: String {
    name.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  public var hostLabel: String {
    URL(string: apiBaseURLString)?.host() ?? apiBaseURLString
  }
}
