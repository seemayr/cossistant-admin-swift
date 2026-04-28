import Foundation

public enum DashboardKnowledgeType: String, Codable, CaseIterable, Identifiable, Sendable {
  case url
  case faq
  case article

  public var id: String { rawValue }

  public var label: String {
    switch self {
    case .url:
      "URL"
    case .faq:
      "FAQ"
    case .article:
      "Article"
    }
  }
}

public struct DashboardPaginationMetadata: Decodable, Hashable, Sendable {
  public let page: Int
  public let limit: Int
  public let total: Int
  public let hasMore: Bool
}

public struct DashboardKnowledgeListResponse: Decodable, Sendable {
  public let items: [DashboardKnowledge]
  public let pagination: DashboardPaginationMetadata
}

public struct DashboardKnowledge: Identifiable, Decodable, Hashable, Sendable {
  public let id: String
  public let organizationId: String
  public let websiteId: String
  public let aiAgentId: String?
  public let linkSourceId: String?
  public let type: DashboardKnowledgeType
  public let sourceUrl: URL?
  public let sourceTitle: String?
  public let origin: String
  public let createdBy: String
  public let contentHash: String
  public let payload: JSONValue
  public let metadata: DashboardMetadata?
  public let isIncluded: Bool
  public let sizeBytes: Int
  public let createdAt: String
  public let updatedAt: String
  public let deletedAt: String?

  public var titleText: String {
    sourceTitle
      ?? faqPayload?.question
      ?? articlePayload?.title
      ?? sourceUrl?.absoluteString
      ?? id
  }

  public var createdAbsoluteText: String {
    DashboardTimestampParser.absoluteString(from: createdAt) ?? createdAt
  }

  public var updatedAbsoluteText: String {
    DashboardTimestampParser.absoluteString(from: updatedAt) ?? updatedAt
  }

  public var faqPayload: DashboardFAQKnowledgePayload? {
    payload.dashboardDecoded(as: DashboardFAQKnowledgePayload.self)
  }

  public var articlePayload: DashboardArticleKnowledgePayload? {
    payload.dashboardDecoded(as: DashboardArticleKnowledgePayload.self)
  }

  public var urlPayload: DashboardURLKnowledgePayload? {
    payload.dashboardDecoded(as: DashboardURLKnowledgePayload.self)
  }
}

public struct DashboardKnowledgeDraft: Codable, Sendable {
  public var aiAgentId: String?
  public var type: DashboardKnowledgeType
  public var sourceUrl: URL?
  public var sourceTitle: String?
  public var origin: String
  public var payload: JSONValue
  public var metadata: DashboardMetadata?
}

public extension DashboardKnowledgeDraft {
  init(
    aiAgentId: String? = nil,
    sourceUrl: URL? = nil,
    sourceTitle: String? = nil,
    origin: String = "manual",
    payload: DashboardURLKnowledgePayload,
    metadata: DashboardMetadata? = nil
  ) {
    self.init(
      aiAgentId: aiAgentId,
      type: .url,
      sourceUrl: sourceUrl,
      sourceTitle: sourceTitle,
      origin: origin,
      payload: payload.dashboardJSONValue,
      metadata: metadata
    )
  }

  init(
    aiAgentId: String? = nil,
    sourceUrl: URL? = nil,
    sourceTitle: String? = nil,
    origin: String = "manual",
    payload: DashboardFAQKnowledgePayload,
    metadata: DashboardMetadata? = nil
  ) {
    self.init(
      aiAgentId: aiAgentId,
      type: .faq,
      sourceUrl: sourceUrl,
      sourceTitle: sourceTitle,
      origin: origin,
      payload: payload.dashboardJSONValue,
      metadata: metadata
    )
  }

  init(
    aiAgentId: String? = nil,
    sourceUrl: URL? = nil,
    sourceTitle: String? = nil,
    origin: String = "manual",
    payload: DashboardArticleKnowledgePayload,
    metadata: DashboardMetadata? = nil
  ) {
    self.init(
      aiAgentId: aiAgentId,
      type: .article,
      sourceUrl: sourceUrl,
      sourceTitle: sourceTitle,
      origin: origin,
      payload: payload.dashboardJSONValue,
      metadata: metadata
    )
  }
}

public enum DashboardKnowledgeAIAgentFilter: Hashable, Sendable {
  case all
  case shared
  case specific(String)

  public var queryValue: String? {
    switch self {
    case .all:
      nil
    case .shared:
      "null"
    case .specific(let id):
      id.trimmingCharacters(in: .whitespacesAndNewlines)
    }
  }
}

public enum DashboardKnowledgeIncludedFilter: String, CaseIterable, Identifiable, Sendable {
  case all
  case included
  case excluded

  public var id: String { rawValue }

  public var label: String {
    switch self {
    case .all:
      "All"
    case .included:
      "Included"
    case .excluded:
      "Excluded"
    }
  }

  public var queryValue: String? {
    switch self {
    case .all:
      nil
    case .included:
      "true"
    case .excluded:
      "false"
    }
  }
}
