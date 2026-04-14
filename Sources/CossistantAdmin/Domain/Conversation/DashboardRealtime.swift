import Foundation

public enum DashboardRealtimeConnectionState: Equatable, Sendable {
  case disconnected
  case connecting
  case connected(connectionID: String?)
  case failed(String)

  public var isConnected: Bool {
    if case .connected = self {
      return true
    }

    return false
  }
}

public struct DashboardRealtimeConnectionEstablishedPayload: Decodable, Sendable {
  public let connectionId: String?
  public let userId: String?
  public let visitorId: String?
  public let organizationId: String?
  public let websiteId: String?
  public let timestamp: Int?
}

public struct DashboardRealtimeConversationSeenPayload: Decodable, Sendable {
  public let websiteId: String
  public let organizationId: String
  public let visitorId: String?
  public let userId: String?
  public let conversationId: String
  public let aiAgentId: String?
  public let lastSeenAt: String
  public let actorType: String
  public let actorId: String
}

public struct DashboardRealtimeConversationTypingPayload: Decodable, Sendable {
  public let websiteId: String
  public let organizationId: String
  public let visitorId: String?
  public let userId: String?
  public let conversationId: String
  public let aiAgentId: String?
  public let isTyping: Bool
  public let visitorPreview: String?
}

public struct DashboardRealtimeAIProcessingStartedPayload: Decodable, Sendable {
  public let websiteId: String
  public let organizationId: String
  public let visitorId: String?
  public let userId: String?
  public let conversationId: String
  public let aiAgentId: String
  public let workflowRunId: String
  public let triggerMessageId: String
  public let phase: String?
  public let audience: String?
}

public struct DashboardRealtimeAIProcessingProgressPayload: Decodable, Sendable {
  public struct Tool: Decodable, Sendable {
    public let toolCallId: String
    public let toolName: String
    public let state: String
  }

  public let websiteId: String
  public let organizationId: String
  public let visitorId: String?
  public let userId: String?
  public let conversationId: String
  public let aiAgentId: String
  public let workflowRunId: String
  public let phase: String
  public let message: String?
  public let tool: Tool?
  public let audience: String?
}

public struct DashboardRealtimeAIProcessingCompletedPayload: Decodable, Sendable {
  public let websiteId: String
  public let organizationId: String
  public let visitorId: String?
  public let userId: String?
  public let conversationId: String
  public let aiAgentId: String
  public let workflowRunId: String
  public let status: String
  public let action: String?
  public let reason: String?
  public let audience: String?
}

public struct DashboardRealtimeAIProcessingState: Equatable, Sendable {
  public let aiAgentId: String
  public let phase: String
  public let message: String?
  public let toolName: String?
  public let toolState: String?

  public init(
    aiAgentId: String,
    phase: String,
    message: String? = nil,
    toolName: String? = nil,
    toolState: String? = nil
  ) {
    self.aiAgentId = aiAgentId
    self.phase = phase
    self.message = message
    self.toolName = toolName
    self.toolState = toolState
  }

  public var phaseDisplayTitle: String {
    switch phase.lowercased() {
    case "thinking":
      return "Thinking"
    case "searching":
      return "Searching"
    case "generating":
      return "Generating"
    case "tool-executing":
      return "Using tools"
    default:
      return phase.replacingOccurrences(of: "-", with: " ").capitalized
    }
  }

  public var statusText: String {
    if let message, !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      return message
    }

    if let toolName, !toolName.isEmpty {
      return "Using \(DashboardTimelineItem.humanizeToolName(toolName))"
    }

    return phaseDisplayTitle
  }
}

public struct DashboardRealtimeTimelineItemPayload: Decodable, Sendable {
  public let websiteId: String
  public let organizationId: String
  public let visitorId: String?
  public let userId: String?
  public let conversationId: String
  public let item: DashboardTimelineItem
}

public struct DashboardRealtimeConversationCreatedPayload: Decodable, Sendable {
  public let websiteId: String
  public let organizationId: String
  public let visitorId: String?
  public let userId: String?
  public let conversationId: String
}

public struct DashboardRealtimeConversationUpdatedPayload: Decodable, Sendable {
  public struct Updates: Decodable, Sendable {
    public let title: String?
    public let status: DashboardConversation.Status?
    public let priority: DashboardConversation.Priority?
    public let resolvedAt: String?
    public let aiPausedUntil: String?
    public let escalatedAt: String?
    public let escalationHandledAt: String?
    public let sentiment: String?
    public let sentimentConfidence: Double?
    public let activeClarification: DashboardConversation.Clarification?
  }

  public let websiteId: String
  public let organizationId: String
  public let visitorId: String?
  public let userId: String?
  public let conversationId: String
  public let updates: Updates
  public let aiAgentId: String?
}

public struct DashboardRealtimeVisitorIdentifiedPayload: Decodable, Sendable {
  public let websiteId: String
  public let organizationId: String
  public let visitorId: String
  public let userId: String?
  public let visitor: DashboardVisitor
}

public struct DashboardRealtimeVisitorConnectionPayload: Decodable, Sendable {
  public let websiteId: String
  public let organizationId: String
  public let visitorId: String
  public let userId: String?
  public let connectionId: String
}

public struct DashboardRealtimeVisitorPresencePayload: Decodable, Sendable {
  public let websiteId: String
  public let organizationId: String
  public let visitorId: String
  public let userId: String?
  public let sessionId: String
  public let activityType: String
}

public enum DashboardRealtimeClientEvent: Sendable {
  case conversationTyping(
    conversationId: String,
    isTyping: Bool,
    visitorPreview: String?
  )
  case conversationSeen(conversationId: String)

  public var type: String {
    switch self {
    case .conversationTyping:
      "conversationTyping"
    case .conversationSeen:
      "conversationSeen"
    }
  }

  public func payload(
    websiteID: String,
    organizationID: String?
  ) -> [String: JSONValue] {
    var payload: [String: JSONValue] = [
      "websiteId": .string(websiteID),
      "organizationId": organizationID.map(JSONValue.string) ?? .null,
      "visitorId": .null,
      "userId": .null,
      "aiAgentId": .null,
    ]

    switch self {
    case .conversationTyping(let conversationId, let isTyping, let visitorPreview):
      payload["conversationId"] = .string(conversationId)
      payload["isTyping"] = .bool(isTyping)
      payload["visitorPreview"] = visitorPreview.map(JSONValue.string) ?? .null
    case .conversationSeen(let conversationId):
      payload["conversationId"] = .string(conversationId)
      payload["lastSeenAt"] = .string(
        ISO8601DateFormatter.dashboardInternetDateTime().string(from: Date.now)
      )
      payload["actorType"] = .string("user")
      payload["actorId"] = .string("api-key")
    }

    return payload
  }
}

public enum DashboardRealtimeEvent: Sendable {
  case connectionEstablished(DashboardRealtimeConnectionEstablishedPayload)
  case conversationSeen(DashboardRealtimeConversationSeenPayload)
  case conversationTyping(DashboardRealtimeConversationTypingPayload)
  case aiAgentProcessingStarted(DashboardRealtimeAIProcessingStartedPayload)
  case aiAgentProcessingProgress(DashboardRealtimeAIProcessingProgressPayload)
  case aiAgentProcessingCompleted(DashboardRealtimeAIProcessingCompletedPayload)
  case timelineItemCreated(DashboardRealtimeTimelineItemPayload)
  case timelineItemUpdated(DashboardRealtimeTimelineItemPayload)
  case conversationCreated(DashboardRealtimeConversationCreatedPayload)
  case conversationUpdated(DashboardRealtimeConversationUpdatedPayload)
  case visitorIdentified(DashboardRealtimeVisitorIdentifiedPayload)
  case visitorConnected(DashboardRealtimeVisitorConnectionPayload)
  case visitorDisconnected(DashboardRealtimeVisitorConnectionPayload)
  case visitorPresenceUpdate(DashboardRealtimeVisitorPresencePayload)
  case serverError(message: String)
  case unsupported(type: String)

  public init(data: Data, decoder: JSONDecoder = JSONDecoder()) throws {
    let envelope = try decoder.decode(DashboardRealtimeEnvelope.self, from: data)

    if let error = envelope.error {
      self = .serverError(message: envelope.message ?? error)
      return
    }

    guard let type = envelope.type else {
      self = .serverError(message: envelope.message ?? "Unknown realtime message.")
      return
    }

    switch type {
    case "CONNECTION_ESTABLISHED":
      self = .connectionEstablished(
        try envelope.decodePayload(
          as: DashboardRealtimeConnectionEstablishedPayload.self,
          decoder: decoder
        )
      )
    case "conversationSeen":
      self = .conversationSeen(
        try envelope.decodePayload(
          as: DashboardRealtimeConversationSeenPayload.self,
          decoder: decoder
        )
      )
    case "conversationTyping":
      self = .conversationTyping(
        try envelope.decodePayload(
          as: DashboardRealtimeConversationTypingPayload.self,
          decoder: decoder
        )
      )
    case "aiAgentProcessingStarted":
      self = .aiAgentProcessingStarted(
        try envelope.decodePayload(
          as: DashboardRealtimeAIProcessingStartedPayload.self,
          decoder: decoder
        )
      )
    case "aiAgentProcessingProgress":
      self = .aiAgentProcessingProgress(
        try envelope.decodePayload(
          as: DashboardRealtimeAIProcessingProgressPayload.self,
          decoder: decoder
        )
      )
    case "aiAgentProcessingCompleted":
      self = .aiAgentProcessingCompleted(
        try envelope.decodePayload(
          as: DashboardRealtimeAIProcessingCompletedPayload.self,
          decoder: decoder
        )
      )
    case "timelineItemCreated":
      self = .timelineItemCreated(
        try envelope.decodePayload(
          as: DashboardRealtimeTimelineItemPayload.self,
          decoder: decoder
        )
      )
    case "timelineItemUpdated":
      self = .timelineItemUpdated(
        try envelope.decodePayload(
          as: DashboardRealtimeTimelineItemPayload.self,
          decoder: decoder
        )
      )
    case "conversationCreated":
      self = .conversationCreated(
        try envelope.decodePayload(
          as: DashboardRealtimeConversationCreatedPayload.self,
          decoder: decoder
        )
      )
    case "conversationUpdated":
      self = .conversationUpdated(
        try envelope.decodePayload(
          as: DashboardRealtimeConversationUpdatedPayload.self,
          decoder: decoder
        )
      )
    case "visitorIdentified":
      self = .visitorIdentified(
        try envelope.decodePayload(
          as: DashboardRealtimeVisitorIdentifiedPayload.self,
          decoder: decoder
        )
      )
    case "visitorConnected":
      self = .visitorConnected(
        try envelope.decodePayload(
          as: DashboardRealtimeVisitorConnectionPayload.self,
          decoder: decoder
        )
      )
    case "visitorDisconnected":
      self = .visitorDisconnected(
        try envelope.decodePayload(
          as: DashboardRealtimeVisitorConnectionPayload.self,
          decoder: decoder
        )
      )
    case "visitorPresenceUpdate":
      self = .visitorPresenceUpdate(
        try envelope.decodePayload(
          as: DashboardRealtimeVisitorPresencePayload.self,
          decoder: decoder
        )
      )
    default:
      self = .unsupported(type: type)
    }
  }
}

private struct DashboardRealtimeEnvelope: Decodable {
  public let type: String?
  public let payload: JSONValue?
  public let error: String?
  public let message: String?

  public func decodePayload<T: Decodable>(
    as type: T.Type,
    decoder: JSONDecoder
  ) throws -> T {
    let payloadData = try JSONEncoder().encode(payload ?? .object([:]))
    return try decoder.decode(T.self, from: payloadData)
  }
}
