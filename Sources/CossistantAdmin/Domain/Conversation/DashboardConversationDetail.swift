import Foundation

public struct DashboardConversationResponse: Decodable, Sendable {
  public let conversation: DashboardConversationDetail
}

public struct DashboardConversationDetail: Identifiable, Decodable, Hashable, Sendable {
  public let id: String
  public let title: String?
  public let visitorTitle: String?
  public let visitorTitleLanguage: String?
  public let visitorLanguage: String?
  public let translationActivatedAt: String?
  public let translationChargedAt: String?
  public let metadata: DashboardMetadata?
  public let createdAt: String
  public let updatedAt: String
  public let visitorId: String
  public let websiteId: String
  public let status: DashboardConversation.Status
  public let visitorRating: Int?
  public let visitorRatingAt: String?
  public let deletedAt: String?
  public let visitorLastSeenAt: String?
  public let lastTimelineItem: DashboardTimelineItem?

  public var updatedAtDate: Date? {
    DashboardTimestampParser.date(from: updatedAt)
  }

  public var updatedRelativeText: String {
    guard let updatedAtDate else { return updatedAt }
    return DashboardTimestampParser.relativeString(
      for: updatedAtDate,
      relativeTo: .now
    )
  }
}
