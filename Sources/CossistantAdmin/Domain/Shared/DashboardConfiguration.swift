import Foundation

public struct DashboardConfiguration: Codable, Equatable, Sendable {
  public var apiBaseURLString: String
  public var privateAPIKey: String
  public var actorUserID: String?

  public init(
    apiBaseURLString: String,
    privateAPIKey: String,
    actorUserID: String? = nil
  ) {
    self.apiBaseURLString = apiBaseURLString
    self.privateAPIKey = privateAPIKey
    self.actorUserID = actorUserID
  }

  public static let production = DashboardConfiguration(
    apiBaseURLString: "https://api.cossistant.com/v1",
    privateAPIKey: ""
  )

  public var trimmedAPIBaseURLString: String {
    apiBaseURLString.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  public var trimmedPrivateAPIKey: String {
    privateAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  public var trimmedActorUserID: String? {
    actorUserID?
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .nilIfEmpty
  }

  public var apiBaseURL: URL? {
    URL(string: trimmedAPIBaseURLString)
  }
}
