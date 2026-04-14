import Foundation

public struct DashboardTimelinePage: Decodable, Sendable {
  public let items: [DashboardTimelineItem]
  public let nextCursor: String?
  public let hasNextPage: Bool
}

public enum DashboardTimelineItemVisibility: String, Codable, Hashable, Sendable {
  case `public`
  case `private`

  public var label: String {
    switch self {
    case .public:
      "Public"
    case .private:
      "Private"
    }
  }
}

public enum DashboardTimelineItemType: String, Codable, Hashable, Sendable {
  case message
  case event
  case identification
  case tool
}

public enum DashboardToolTimelineLogType: String, Codable, Hashable, Sendable {
  case customerFacing = "customer_facing"
  case log
  case decision
}

public struct DashboardTimelineItem: Identifiable, Decodable, Hashable, Sendable {
  public let id: String
  public let conversationId: String
  public let organizationId: String
  public let visibility: DashboardTimelineItemVisibility
  public let type: DashboardTimelineItemType
  public let text: String?
  public let tool: String?
  public let parts: [DashboardTimelinePart]
  public let userId: String?
  public let aiAgentId: String?
  public let visitorId: String?
  public let createdAt: String
  public let deletedAt: String?

  public enum CodingKeys: String, CodingKey {
    case id
    case conversationId
    case organizationId
    case visibility
    case type
    case text
    case tool
    case parts
    case userId
    case aiAgentId
    case visitorId
    case createdAt
    case deletedAt
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    conversationId = try container.decode(String.self, forKey: .conversationId)
    organizationId = try container.decode(String.self, forKey: .organizationId)
    visibility = try container.decode(DashboardTimelineItemVisibility.self, forKey: .visibility)
    type = try container.decode(DashboardTimelineItemType.self, forKey: .type)
    text = try container.decodeIfPresent(String.self, forKey: .text)
    tool = try container.decodeIfPresent(String.self, forKey: .tool)
    parts = try container.decodeIfPresent([DashboardTimelinePart].self, forKey: .parts) ?? []
    userId = try container.decodeIfPresent(String.self, forKey: .userId)
    aiAgentId = try container.decodeIfPresent(String.self, forKey: .aiAgentId)
    visitorId = try container.decodeIfPresent(String.self, forKey: .visitorId)
    createdAt = try container.decode(String.self, forKey: .createdAt)
    deletedAt = try container.decodeIfPresent(String.self, forKey: .deletedAt)
  }

  public var createdAtDate: Date? {
    DashboardTimestampParser.date(from: createdAt)
  }

  public var createdRelativeText: String {
    guard let createdAtDate else { return createdAt }
    return RelativeDateTimeFormatter.dashboardFormatter().localizedString(
      for: createdAtDate,
      relativeTo: Date.now
    )
  }

  public var createdTimeText: String {
    guard let createdAtDate else { return createdAt }
    return createdAtDate.formatted(.dateTime.hour().minute())
  }

  public var textParts: [DashboardTimelineTextPart] {
    parts.compactMap {
      guard case .text(let part) = $0 else { return nil }
      return part
    }
  }

  public var fileParts: [DashboardTimelineFilePart] {
    parts.compactMap {
      guard case .file(let part) = $0 else { return nil }
      return part
    }
  }

  public var imageParts: [DashboardTimelineImagePart] {
    parts.compactMap {
      guard case .image(let part) = $0 else { return nil }
      return part
    }
  }

  public var metadataParts: [DashboardTimelineMetadataPart] {
    parts.compactMap {
      guard case .metadata(let part) = $0 else { return nil }
      return part
    }
  }

  public var toolPart: DashboardTimelineToolPart? {
    parts.first {
      guard case .tool = $0 else { return false }
      return true
    }.flatMap {
      guard case .tool(let part) = $0 else { return nil }
      return part
    }
  }

  public var eventPart: DashboardTimelineEventPart? {
    parts.first {
      guard case .event = $0 else { return false }
      return true
    }.flatMap {
      guard case .event(let part) = $0 else { return nil }
      return part
    }
  }

  public var renderedText: String? {
    let collectedText = textParts
      .map(\.text)
      .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
      .joined(separator: "\n\n")

    if !collectedText.isEmpty {
      return collectedText
    }

    if let text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      return text
    }

    return nil
  }

  public var previewText: String {
    if let renderedText {
      return renderedText
    }

    if let eventPreviewText {
      return eventPreviewText
    }

    if let toolSummary {
      return toolSummary
    }

    if !imageParts.isEmpty {
      return "\(imageParts.count) image\(imageParts.count == 1 ? "" : "s")"
    }

    if !fileParts.isEmpty {
      return "\(fileParts.count) file\(fileParts.count == 1 ? "" : "s")"
    }

    return "No text payload"
  }

  public var sourceLabel: String? {
    guard let source = metadataParts.first?.source else { return nil }
    return source.replacingOccurrences(of: "_", with: " ").capitalized
  }

  public var toolDisplayName: String? {
    if let toolName = toolPart?.toolName, !toolName.isEmpty {
      return Self.humanizeToolName(toolName)
    }

    guard let tool, !tool.isEmpty else { return nil }
    return Self.humanizeToolName(tool)
  }

  public var toolSummary: String? {
    if let text, !text.isEmpty {
      return text
    }

    if let progressMessage = toolPart?.progressMessage, !progressMessage.isEmpty {
      return progressMessage
    }

    return toolDisplayName
  }

  public var toolLogType: DashboardToolTimelineLogType {
    if let metadataType = toolPart?.toolTimelineMetadata?.logType {
      return metadataType
    }

    return .log
  }

  public var isCustomerFacingTool: Bool {
    type == .tool && toolLogType == .customerFacing
  }

  public var isDeveloperLog: Bool {
    type == .tool && toolLogType != .customerFacing
  }

  public var isPrivateNote: Bool {
    type == .message && visibility == .private
  }

  public var eventPreviewText: String? {
    if let message = eventPart?.message, !message.isEmpty {
      return message
    }

    if let text, !text.isEmpty {
      return text
    }

    guard let eventPart else { return nil }
    return Self.defaultEventText(for: eventPart.eventType)
  }

  public var attachmentSummary: String? {
    let imageCount = imageParts.count
    let fileCount = fileParts.count
    let parts = [
      imageCount > 0 ? "\(imageCount) image\(imageCount == 1 ? "" : "s")" : nil,
      fileCount > 0 ? "\(fileCount) file\(fileCount == 1 ? "" : "s")" : nil,
    ].compactMap { $0 }

    guard !parts.isEmpty else { return nil }
    return parts.joined(separator: " • ")
  }

  public static func humanizeToolName(_ rawValue: String) -> String {
    let withSeparators = rawValue
      .unicodeScalars
      .enumerated()
      .reduce(into: "") { result, entry in
        let (index, scalar) = entry
        let character = Character(scalar)

        if character == "-" || character == "_" {
          result.append(" ")
          return
        }

        if index > 0, CharacterSet.uppercaseLetters.contains(scalar) {
          result.append(" ")
        }

        result.append(character)
      }

    return withSeparators
      .split(whereSeparator: \.isWhitespace)
      .map { $0.capitalized }
      .joined(separator: " ")
  }

  public static func defaultEventText(for eventType: String) -> String {
    switch eventType {
    case "assigned":
      "Assigned the conversation"
    case "unassigned":
      "Unassigned the conversation"
    case "participant_requested":
      "Requested a team member to join"
    case "participant_joined":
      "Joined the conversation"
    case "participant_left":
      "Left the conversation"
    case "status_changed":
      "Changed the status"
    case "priority_changed":
      "Changed the priority"
    case "tag_added":
      "Added a tag"
    case "tag_removed":
      "Removed a tag"
    case "resolved":
      "Resolved the conversation"
    case "reopened":
      "Reopened the conversation"
    case "visitor_blocked":
      "Blocked the visitor"
    case "visitor_unblocked":
      "Unblocked the visitor"
    case "visitor_identified":
      "Identified the visitor"
    case "ai_paused":
      "Paused AI answers"
    case "ai_resumed":
      "Resumed AI answers"
    default:
      eventType.replacingOccurrences(of: "_", with: " ").capitalized
    }
  }
}

extension DashboardTimelineItem: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(conversationId, forKey: .conversationId)
    try container.encode(organizationId, forKey: .organizationId)
    try container.encode(visibility, forKey: .visibility)
    try container.encode(type, forKey: .type)
    try container.encodeIfPresent(text, forKey: .text)
    try container.encodeIfPresent(tool, forKey: .tool)
    try container.encode(parts, forKey: .parts)
    try container.encodeIfPresent(userId, forKey: .userId)
    try container.encodeIfPresent(aiAgentId, forKey: .aiAgentId)
    try container.encodeIfPresent(visitorId, forKey: .visitorId)
    try container.encode(createdAt, forKey: .createdAt)
    try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
  }
}

public enum DashboardTimelinePart: Hashable, Sendable {
  case text(DashboardTimelineTextPart)
  case reasoning(DashboardTimelineReasoningPart)
  case tool(DashboardTimelineToolPart)
  case sourceURL(DashboardTimelineSourceURLPart)
  case sourceDocument(DashboardTimelineSourceDocumentPart)
  case stepStart
  case file(DashboardTimelineFilePart)
  case image(DashboardTimelineImagePart)
  case event(DashboardTimelineEventPart)
  case metadata(DashboardTimelineMetadataPart)
  case unknown(DashboardTimelineUnknownPart)
}

extension DashboardTimelinePart: Decodable {
  private enum CodingKeys: String, CodingKey {
    case type
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .type)

    switch type {
    case "text":
      self = .text(try DashboardTimelineTextPart(from: decoder))
    case "reasoning":
      self = .reasoning(try DashboardTimelineReasoningPart(from: decoder))
    case "source-url":
      self = .sourceURL(try DashboardTimelineSourceURLPart(from: decoder))
    case "source-document":
      self = .sourceDocument(try DashboardTimelineSourceDocumentPart(from: decoder))
    case "step-start":
      self = .stepStart
    case "file":
      self = .file(try DashboardTimelineFilePart(from: decoder))
    case "image":
      self = .image(try DashboardTimelineImagePart(from: decoder))
    case "event":
      self = .event(try DashboardTimelineEventPart(from: decoder))
    case "metadata":
      self = .metadata(try DashboardTimelineMetadataPart(from: decoder))
    default:
      if type.hasPrefix("tool-") {
        self = .tool(try DashboardTimelineToolPart(from: decoder))
      } else {
        self = .unknown(try DashboardTimelineUnknownPart(from: decoder))
      }
    }
  }
}

extension DashboardTimelinePart: Encodable {
  public func encode(to encoder: Encoder) throws {
    switch self {
    case .text(let part):
      try part.encode(to: encoder)
    case .reasoning(let part):
      try part.encode(to: encoder)
    case .tool(let part):
      try part.encode(to: encoder)
    case .sourceURL(let part):
      try part.encode(to: encoder)
    case .sourceDocument(let part):
      try part.encode(to: encoder)
    case .stepStart:
      var container = encoder.container(keyedBy: DashboardTimelinePartCodingKeys.self)
      try container.encode("step-start", forKey: .type)
    case .file(let part):
      try part.encode(to: encoder)
    case .image(let part):
      try part.encode(to: encoder)
    case .event(let part):
      try part.encode(to: encoder)
    case .metadata(let part):
      try part.encode(to: encoder)
    case .unknown(let part):
      try part.encode(to: encoder)
    }
  }
}

private enum DashboardTimelinePartCodingKeys: String, CodingKey {
  case type
}

public struct DashboardTimelineTextPart: Codable, Hashable, Sendable {
  public let type: String
  public let text: String
  public let state: String?
}

public struct DashboardTimelineReasoningPart: Codable, Hashable, Sendable {
  public let type: String
  public let text: String
  public let state: String?
}

public struct DashboardTimelineSourceURLPart: Codable, Hashable, Sendable {
  public let type: String
  public let sourceId: String
  public let url: String
  public let title: String?
}

public struct DashboardTimelineSourceDocumentPart: Codable, Hashable, Sendable {
  public let type: String
  public let sourceId: String
  public let mediaType: String
  public let title: String
  public let filename: String?
}

public struct DashboardTimelineFilePart: Codable, Hashable, Sendable {
  public let type: String
  public let url: String
  public let mediaType: String
  public let filename: String?
  public let size: Int?
}

public struct DashboardTimelineImagePart: Codable, Hashable, Sendable {
  public let type: String
  public let url: String
  public let mediaType: String
  public let filename: String?
  public let size: Int?
  public let width: Int?
  public let height: Int?
}

public struct DashboardTimelineEventPart: Codable, Hashable, Sendable {
  public let type: String
  public let eventType: String
  public let actorUserId: String?
  public let actorAiAgentId: String?
  public let targetUserId: String?
  public let targetAiAgentId: String?
  public let message: String?
}

public struct DashboardTimelineMetadataPart: Codable, Hashable, Sendable {
  public let type: String
  public let source: String
}

public struct DashboardTimelineToolPart: Codable, Hashable, Sendable {
  public let type: String
  public let toolCallId: String
  public let toolName: String
  public let input: [String: JSONValue]?
  public let output: JSONValue?
  public let state: String
  public let errorText: String?
  public let callProviderMetadata: DashboardTimelineProviderMetadata?
  public let providerMetadata: DashboardTimelineProviderMetadata?

  public var progressMessage: String? {
    callProviderMetadata?.cossistant?.progressMessage
      ?? providerMetadata?.cossistant?.progressMessage
  }

  public var toolTimelineMetadata: DashboardTimelineToolMetadata? {
    callProviderMetadata?.cossistant?.toolTimeline
      ?? providerMetadata?.cossistant?.toolTimeline
  }
}

public struct DashboardTimelineProviderMetadata: Codable, Hashable, Sendable {
  public let cossistant: DashboardTimelineCossistantMetadata?
}

public struct DashboardTimelineCossistantMetadata: Codable, Hashable, Sendable {
  public let visibility: DashboardTimelineItemVisibility?
  public let progressMessage: String?
  public let knowledgeId: String?
  public let toolTimeline: DashboardTimelineToolMetadata?
}

public struct DashboardTimelineToolMetadata: Codable, Hashable, Sendable {
  public let logType: DashboardToolTimelineLogType?
  public let triggerMessageId: String?
  public let workflowRunId: String?
  public let triggerVisibility: DashboardTimelineItemVisibility?
}

public struct DashboardTimelineUnknownPart: Decodable, Hashable, Sendable {
  public let type: String
  public let payload: [String: JSONValue]

  private enum CodingKeys: String, CodingKey {
    case type
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    payload = try container.decode([String: JSONValue].self)
    type = payload["type"]?.stringValue ?? "unknown"
  }
}

extension DashboardTimelineUnknownPart: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(payload)
  }
}

private extension JSONValue {
  var stringValue: String? {
    guard case .string(let value) = self else { return nil }
    return value
  }
}
