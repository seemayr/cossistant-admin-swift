import Foundation

public struct EmptyResponse: Decodable, Sendable {}

public struct DashboardConversationSeenResponse: Decodable, Sendable {
  public let seenData: [DashboardConversationSeen]
}

public struct DashboardConversationSeen: Identifiable, Decodable, Hashable, Sendable {
  public let id: String
  public let conversationId: String
  public let userId: String?
  public let visitorId: String?
  public let aiAgentId: String?
  public let lastSeenAt: String
  public let createdAt: String
  public let updatedAt: String
  public let deletedAt: String?

  public init(
    id: String,
    conversationId: String,
    userId: String? = nil,
    visitorId: String? = nil,
    aiAgentId: String? = nil,
    lastSeenAt: String,
    createdAt: String,
    updatedAt: String,
    deletedAt: String? = nil
  ) {
    self.id = id
    self.conversationId = conversationId
    self.userId = userId
    self.visitorId = visitorId
    self.aiAgentId = aiAgentId
    self.lastSeenAt = lastSeenAt
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.deletedAt = deletedAt
  }

  public var actorLabel: String {
    if userId != nil {
      return "Human agent"
    }

    if aiAgentId != nil {
      return "AI agent"
    }

    if visitorId != nil {
      return "Visitor"
    }

    return "Unknown actor"
  }

  public var lastSeenDate: Date? {
    DashboardTimestampParser.date(from: lastSeenAt)
  }
}

public struct DashboardConversationTypingRequest: Encodable, Sendable {
  public let isTyping: Bool
  public var visitorPreview: String?
  public var visitorId: String?

  public init(
    isTyping: Bool,
    visitorPreview: String? = nil,
    visitorId: String? = nil
  ) {
    self.isTyping = isTyping
    self.visitorPreview = visitorPreview
    self.visitorId = visitorId
  }
}

public struct DashboardConversationTypingResponse: Decodable, Sendable {
  public let conversationId: String
  public let isTyping: Bool
  public let visitorPreview: String?
  public let sentAt: String
}

public struct DashboardTimelineItemDraft: Encodable, Sendable {
  public var id: String?
  public var type: String = "message"
  public var text: String
  public var parts: [JSONValue]?
  public var visibility: String = "public"
  public var tool: String?
  public var userId: String?
  public var aiAgentId: String?
  public var visitorId: String?
  public var createdAt: String?

  public static func message(
    _ text: String,
    visibility: String = "public",
    userID: String? = nil,
    aiAgentID: String? = nil,
    visitorID: String? = nil,
    parts: [JSONValue]? = nil
  ) -> DashboardTimelineItemDraft {
    DashboardTimelineItemDraft(
      text: text,
      parts: parts,
      visibility: visibility,
      userId: userID,
      aiAgentId: aiAgentID,
      visitorId: visitorID
    )
  }

  public init(
    id: String? = nil,
    type: String = "message",
    text: String,
    parts: [JSONValue]? = nil,
    visibility: String = "public",
    tool: String? = nil,
    userId: String? = nil,
    aiAgentId: String? = nil,
    visitorId: String? = nil,
    createdAt: String? = nil
  ) {
    self.id = id
    self.type = type
    self.text = text
    self.parts = parts
    self.visibility = visibility
    self.tool = tool
    self.userId = userId
    self.aiAgentId = aiAgentId
    self.visitorId = visitorId
    self.createdAt = createdAt
  }
}

public struct DashboardSendTimelineItemRequest: Encodable, Sendable {
  public let conversationId: String
  public let item: DashboardTimelineItemDraft

  public init(
    conversationId: String,
    item: DashboardTimelineItemDraft
  ) {
    self.conversationId = conversationId
    self.item = item
  }
}

public struct DashboardSendTimelineItemResponse: Decodable, Sendable {
  public let item: DashboardTimelineItem
}

public struct DashboardConversationMutation: Decodable, Sendable {
  public let id: String
  public let organizationId: String
  public let visitorId: String
  public let websiteId: String
  public let metadata: DashboardMetadata?
  public let status: DashboardConversation.Status
  public let priority: DashboardConversation.Priority
  public let sentiment: String?
  public let sentimentConfidence: Double?
  public let channel: String
  public let title: String?
  public let visitorRating: Int?
  public let resolvedAt: String?
  public let resolvedByUserId: String?
  public let resolvedByAiAgentId: String?
  public let escalatedAt: String?
  public let escalationHandledAt: String?
  public let aiPausedUntil: String?
  public let createdAt: String
  public let updatedAt: String
  public let deletedAt: String?
  public let lastMessageAt: String?
  public let lastSeenAt: String?
}

public struct DashboardConversationMutationResponse: Decodable, Sendable {
  public let conversation: DashboardConversationMutation
}

public struct DashboardPauseConversationAIRequest: Encodable, Sendable {
  public let durationMinutes: Int
}

public struct DashboardUpdateConversationTitleRequest: Encodable, Sendable {
  public let title: String?
}

public struct DashboardUpdateConversationMetadataRequest: Encodable, Sendable {
  public let metadata: DashboardMetadata
}
