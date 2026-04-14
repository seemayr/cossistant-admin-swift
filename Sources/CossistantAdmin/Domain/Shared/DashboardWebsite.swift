import Foundation

public struct DashboardWebsite: Decodable, Sendable {
  public struct HumanAgent: Decodable, Hashable, Sendable, Identifiable {
    public let id: String
    public let name: String?
    public let image: URL?
    public let lastSeenAt: String?

    public var displayName: String {
      if let name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        return name
      }

      return "Team member"
    }
  }

  public struct AIAgent: Decodable, Hashable, Sendable, Identifiable {
    public let id: String
    public let name: String?
    public let image: URL?

    public var displayName: String {
      if let name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        return name
      }

      return "AI agent"
    }
  }

  public let id: String
  public let name: String
  public let domain: String?
  public let description: String?
  public let logoURL: URL?
  public let organizationId: String
  public let status: String
  public let lastOnlineAt: String?
  public let availableHumanAgents: [HumanAgent]
  public let availableAIAgents: [AIAgent]

  public enum CodingKeys: String, CodingKey {
    case id
    case name
    case domain
    case description
    case logoURL = "logoUrl"
    case organizationId
    case status
    case lastOnlineAt
    case availableHumanAgents
    case availableAIAgents
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    name = try container.decode(String.self, forKey: .name)
    domain = try container.decodeIfPresent(String.self, forKey: .domain)
    description = try container.decodeIfPresent(String.self, forKey: .description)
    logoURL = try container.decodeIfPresent(URL.self, forKey: .logoURL)
    organizationId = try container.decode(String.self, forKey: .organizationId)
    status = try container.decode(String.self, forKey: .status)
    lastOnlineAt = try container.decodeIfPresent(String.self, forKey: .lastOnlineAt)
    availableHumanAgents = try container.decodeIfPresent([HumanAgent].self, forKey: .availableHumanAgents) ?? []
    availableAIAgents = try container.decodeIfPresent([AIAgent].self, forKey: .availableAIAgents) ?? []
  }
}
