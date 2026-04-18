import Foundation

public enum DashboardConversationSentiment: String, CaseIterable, Identifiable, Sendable {
  case positive
  case neutral
  case negative
  case unknown

  public var id: String { rawValue }

  public var label: String {
    switch self {
    case .positive:
      "Positive"
    case .neutral:
      "Neutral"
    case .negative:
      "Negative"
    case .unknown:
      "Unknown"
    }
  }
}

public struct DashboardConversationPage: Decodable, Sendable {
  public let items: [DashboardConversation]
  public let nextCursor: String?
}

public struct DashboardConversation: Identifiable, Decodable, Hashable, Sendable {
  public struct Clarification: Decodable, Hashable, Sendable {
    public let requestId: String
    public let status: String
    public let question: String?
    public let updatedAt: String
  }

  public struct Visitor: Decodable, Hashable, Sendable {
    public struct Contact: Decodable, Hashable, Sendable {
      public let id: String
      public let name: String?
      public let email: String?
      public let image: URL?
      public let metadata: DashboardMetadata?
    }

    public let id: String
    public let lastSeenAt: String?
    public let isBlocked: Bool
    public let contact: Contact?
  }

  public struct TimelineItem: Decodable, Hashable, Sendable {
    public let id: String?
    public let type: String
    public let text: String?
    public let parts: [DashboardTimelinePart]
    public let userId: String?
    public let aiAgentId: String?
    public let visitorId: String?
    public let createdAt: String

    private enum CodingKeys: String, CodingKey {
      case id
      case type
      case text
      case parts
      case userId
      case aiAgentId
      case visitorId
      case createdAt
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      id = try container.decodeIfPresent(String.self, forKey: .id)
      type = try container.decode(String.self, forKey: .type)
      text = try container.decodeIfPresent(String.self, forKey: .text)
      parts = try container.decodeIfPresent([DashboardTimelinePart].self, forKey: .parts) ?? []
      userId = try container.decodeIfPresent(String.self, forKey: .userId)
      aiAgentId = try container.decodeIfPresent(String.self, forKey: .aiAgentId)
      visitorId = try container.decodeIfPresent(String.self, forKey: .visitorId)
      createdAt = try container.decode(String.self, forKey: .createdAt)
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

      guard let text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        return nil
      }

      return text
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

    public var eventPreviewText: String? {
      if let message = eventPart?.message, !message.isEmpty {
        return message
      }

      guard let text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        return nil
      }

      return text
    }

    public var previewText: String {
      if let renderedText {
        return renderedText
      }

      if type == "event", let eventPreviewText {
        return eventPreviewText
      }

      if let attachmentSummary {
        return attachmentSummary
      }

      return "No message content yet."
    }
  }

  public enum Status: String, Decodable, Hashable, Sendable {
    case open
    case resolved
    case spam

    public var label: String {
      rawValue.capitalized
    }
  }

  public enum Priority: String, Decodable, Hashable, Sendable {
    case low
    case normal
    case high
    case urgent

    public var label: String {
      rawValue.capitalized
    }
  }

  public let id: String
  public let status: Status
  public let priority: Priority
  public let organizationId: String
  public let visitorId: String
  public let visitor: Visitor
  public let websiteId: String
  public let metadata: DashboardMetadata?
  public let channel: String
  public let title: String?
  public let visitorTitle: String?
  public let visitorTitleLanguage: String?
  public let visitorLanguage: String?
  public let titleSource: String?
  public let translationActivatedAt: String?
  public let translationChargedAt: String?
  public let sentiment: String?
  public let sentimentConfidence: Double?
  public let visitorRating: Int?
  public let createdAt: String
  public let updatedAt: String
  public let deletedAt: String?
  public let lastMessageAt: String?
  public let lastSeenAt: String?
  public let escalatedAt: String?
  public let escalationHandledAt: String?
  public let aiPausedUntil: String?
  public let lastMessageTimelineItem: TimelineItem?
  public let lastTimelineItem: TimelineItem?
  public let activeClarification: Clarification?
  public let dashboardLocked: Bool?
  public let dashboardLockReason: String?

  public init(
    id: String,
    status: Status,
    priority: Priority,
    organizationId: String,
    visitorId: String,
    visitor: Visitor,
    websiteId: String,
    metadata: DashboardMetadata? = nil,
    channel: String,
    title: String? = nil,
    visitorTitle: String? = nil,
    visitorTitleLanguage: String? = nil,
    visitorLanguage: String? = nil,
    titleSource: String? = nil,
    translationActivatedAt: String? = nil,
    translationChargedAt: String? = nil,
    sentiment: String? = nil,
    sentimentConfidence: Double? = nil,
    visitorRating: Int? = nil,
    createdAt: String,
    updatedAt: String,
    deletedAt: String? = nil,
    lastMessageAt: String? = nil,
    lastSeenAt: String? = nil,
    escalatedAt: String? = nil,
    escalationHandledAt: String? = nil,
    aiPausedUntil: String? = nil,
    lastMessageTimelineItem: TimelineItem? = nil,
    lastTimelineItem: TimelineItem? = nil,
    activeClarification: Clarification? = nil,
    dashboardLocked: Bool? = nil,
    dashboardLockReason: String? = nil
  ) {
    self.id = id
    self.status = status
    self.priority = priority
    self.organizationId = organizationId
    self.visitorId = visitorId
    self.visitor = visitor
    self.websiteId = websiteId
    self.metadata = metadata
    self.channel = channel
    self.title = title
    self.visitorTitle = visitorTitle
    self.visitorTitleLanguage = visitorTitleLanguage
    self.visitorLanguage = visitorLanguage
    self.titleSource = titleSource
    self.translationActivatedAt = translationActivatedAt
    self.translationChargedAt = translationChargedAt
    self.sentiment = sentiment
    self.sentimentConfidence = sentimentConfidence
    self.visitorRating = visitorRating
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.deletedAt = deletedAt
    self.lastMessageAt = lastMessageAt
    self.lastSeenAt = lastSeenAt
    self.escalatedAt = escalatedAt
    self.escalationHandledAt = escalationHandledAt
    self.aiPausedUntil = aiPausedUntil
    self.lastMessageTimelineItem = lastMessageTimelineItem
    self.lastTimelineItem = lastTimelineItem
    self.activeClarification = activeClarification
    self.dashboardLocked = dashboardLocked
    self.dashboardLockReason = dashboardLockReason
  }

  public var displayTitle: String {
    resolvedTitle
  }

  public var resolvedTitle: String {
    if let title, !title.isEmpty {
      return title
    }

    return "Untitled conversation"
  }

  public var visitorDisplayName: String {
    DashboardIdentity.visitorDisplayName(
      contactName: visitor.contact?.name,
      email: visitor.contact?.email,
      visitorID: visitor.id
    )
  }

  public var visitorSecondaryLine: String {
    if let email = visitor.contact?.email, !email.isEmpty {
      return email
    }

    return "Visitor \(visitor.id.suffix(6))"
  }

  public var visitorShortID: String {
    String(visitor.id.prefix(4))
  }

  public var showsVisitorIDInSecondaryLine: Bool {
    if let email = visitor.contact?.email, !email.isEmpty {
      return false
    }

    return true
  }

  public var previewText: String {
    if let lastMessageTimelineItem {
      return lastMessageTimelineItem.previewText
    }

    if let lastTimelineItem {
      return lastTimelineItem.previewText
    }

    return "No message content yet."
  }

  public var hasContent: Bool {
    lastMessageTimelineItem != nil
  }

  public var updatedAtDate: Date? {
    DashboardTimestampParser.date(from: updatedAt)
  }

  public var createdAtDate: Date? {
    DashboardTimestampParser.date(from: createdAt)
  }

  public var lastMessageAtDate: Date? {
    guard let lastMessageAt else { return nil }
    return DashboardTimestampParser.date(from: lastMessageAt)
  }

  public var lastSeenAtDate: Date? {
    guard let lastSeenAt else { return nil }
    return DashboardTimestampParser.date(from: lastSeenAt)
  }

  public var latestMessageWasSentByHumanTeammate: Bool {
    lastMessageTimelineItem?.userId != nil
  }

  public var effectiveSeenDate: Date? {
    lastSeenAtDate
  }

  public var latestActivityDate: Date {
    lastMessageAtDate ?? updatedAtDate ?? createdAtDate ?? .distantPast
  }

  public var isArchived: Bool {
    deletedAt != nil
  }

  public var hasUnreadActivity: Bool {
    guard hasContent else { return false }
    if latestMessageWasSentByHumanTeammate {
      return false
    }

    guard let effectiveSeenDate else { return true }
    return latestActivityDate > effectiveSeenDate
  }

  public var isSeenByTeam: Bool {
    !hasUnreadActivity
  }

  public var createdRelativeText: String {
    guard let createdAtDate else { return createdAt }
    return RelativeDateTimeFormatter.dashboardFormatter().localizedString(
      for: createdAtDate,
      relativeTo: Date.now
    )
  }

  public var lastActivityRelativeText: String {
    let referenceDate = lastMessageAtDate ?? updatedAtDate ?? createdAtDate
    guard let referenceDate else { return updatedAt }
    return RelativeDateTimeFormatter.dashboardFormatter().localizedString(
      for: referenceDate,
      relativeTo: Date.now
    )
  }

  public var needsHumanIntervention: Bool {
    escalatedAt != nil && escalationHandledAt == nil
  }

  public var needsClarification: Bool {
    activeClarification != nil && !needsHumanIntervention
  }

  public var attentionWaitingSinceDate: Date? {
    guard status == .open else { return nil }

    if needsHumanIntervention, let escalatedAt {
      return DashboardTimestampParser.date(from: escalatedAt)
    }

    if needsClarification, let updatedAt = activeClarification?.updatedAt {
      return DashboardTimestampParser.date(from: updatedAt)
    }

    return nil
  }

  public var attentionWaitingDuration: TimeInterval? {
    guard let attentionWaitingSinceDate else { return nil }
    return max(0, Date.now.timeIntervalSince(attentionWaitingSinceDate))
  }

  public var showsAttentionWaitingBadge: Bool {
    guard let attentionWaitingDuration else { return false }
    return attentionWaitingDuration >= 10 * 60 * 60
  }

  public var attentionWaitingLabel: String? {
    guard let attentionWaitingDuration, showsAttentionWaitingBadge else {
      return nil
    }

    let hours = Int(attentionWaitingDuration / 3600)
    if hours < 24 {
      return "Waiting \(hours)h"
    }

    let days = hours / 24
    return "Waiting \(days)d"
  }

  public var showsPriorityIndicator: Bool {
    priority != .normal
  }

  public var sentimentCategory: DashboardConversationSentiment {
    guard let sentiment,
          let category = DashboardConversationSentiment(rawValue: sentiment) else {
      return .unknown
    }

    return category
  }

  public var sentimentSortRank: Int {
    switch sentimentCategory {
    case .negative:
      3
    case .neutral:
      2
    case .positive:
      1
    case .unknown:
      0
    }
  }

  public var channelLabel: String {
    channel.replacingOccurrences(of: "_", with: " ").capitalized
  }

  public var sentimentSummary: String {
    [
      sentiment?.capitalized,
      sentimentConfidence.map {
        "Confidence \($0.formatted(.number.precision(.fractionLength(2))))"
      },
    ]
      .compactMap { $0 }
      .joined(separator: " • ")
      .dashboardFallback("Not available yet")
  }

  public var ratingSummary: String {
    [
      visitorRating.map { "Visitor rating \($0)/5" },
      (dashboardLocked ?? false)
        ? "Dashboard locked: \(dashboardLockReason ?? "conversation_limit")"
        : "Dashboard access available",
    ]
      .compactMap { $0 }
      .joined(separator: " • ")
  }

  public var visitorAvatarURL: URL? {
    visitor.contact?.image
  }

  public var visitorAvatarSeed: String {
    visitor.contact?.email ?? visitor.id
  }

  public func withLastSeenAt(_ value: String?) -> DashboardConversation {
    DashboardConversation(
      id: id,
      status: status,
      priority: priority,
      organizationId: organizationId,
      visitorId: visitorId,
      visitor: visitor,
      websiteId: websiteId,
      metadata: metadata,
      channel: channel,
      title: title,
      visitorTitle: visitorTitle,
      visitorTitleLanguage: visitorTitleLanguage,
      visitorLanguage: visitorLanguage,
      titleSource: titleSource,
      translationActivatedAt: translationActivatedAt,
      translationChargedAt: translationChargedAt,
      sentiment: sentiment,
      sentimentConfidence: sentimentConfidence,
      visitorRating: visitorRating,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      lastMessageAt: lastMessageAt,
      lastSeenAt: value,
      escalatedAt: escalatedAt,
      escalationHandledAt: escalationHandledAt,
      aiPausedUntil: aiPausedUntil,
      lastMessageTimelineItem: lastMessageTimelineItem,
      lastTimelineItem: lastTimelineItem,
      activeClarification: activeClarification,
      dashboardLocked: dashboardLocked,
      dashboardLockReason: dashboardLockReason
    )
  }

  public var priorityRank: Int {
    switch priority {
    case .urgent:
      4
    case .high:
      3
    case .normal:
      2
    case .low:
      1
    }
  }

}

private extension String {
  func dashboardFallback(_ fallback: String) -> String {
    isEmpty ? fallback : self
  }
}

public extension ISO8601DateFormatter {
  static var internetDateTime: ISO8601DateFormatter {
    dashboardInternetDateTime()
  }

  static func dashboardWithFractionalSeconds() -> ISO8601DateFormatter {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }

  static func dashboardInternetDateTime() -> ISO8601DateFormatter {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter
  }
}

public extension RelativeDateTimeFormatter {
  static var dashboard: RelativeDateTimeFormatter {
    dashboardFormatter()
  }

  static func dashboardFormatter() -> RelativeDateTimeFormatter {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .short
    return formatter
  }
}
