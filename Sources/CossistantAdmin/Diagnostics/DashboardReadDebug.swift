import Foundation
import OSLog

public enum DashboardReadDebug {
  public static let targetConversationID = "COJNDDX2Y45YESTQ1B"
  private static let logger = Logger(
    subsystem: "com.cossistant.admin",
    category: "ReadDebug"
  )

  public static func isTargetConversation(_ conversationID: String?) -> Bool {
    conversationID == targetConversationID
  }

  public static func isTargetPath(_ path: String) -> Bool {
    path.contains(targetConversationID)
  }

  public static func log(_ scope: String, _ message: @autoclosure () -> String) {
    let line = "[ReadDebug][\(scope)][\(targetConversationID)] \(message())"
    logger.debug("\(line, privacy: .public)")
  }

  public static func conversationSummary(_ conversation: DashboardConversation) -> String {
    [
      "status=\(conversation.status.rawValue)",
      "priority=\(conversation.priority.rawValue)",
      "lastSeenAt=\(conversation.lastSeenAt ?? "nil")",
      "lastMessageAt=\(conversation.lastMessageAt ?? "nil")",
      "updatedAt=\(conversation.updatedAt)",
      "latestActivity=\(iso(conversation.latestActivityDate))",
      "hasContent=\(conversation.hasContent)",
      "hasUnread=\(conversation.hasUnreadActivity)",
    ]
      .joined(separator: " ")
  }

  public static func mutationSummary(_ mutation: DashboardConversationMutation) -> String {
    [
      "status=\(mutation.status.rawValue)",
      "priority=\(mutation.priority.rawValue)",
      "lastSeenAt=\(mutation.lastSeenAt ?? "nil")",
      "lastMessageAt=\(mutation.lastMessageAt ?? "nil")",
      "updatedAt=\(mutation.updatedAt)",
      "deletedAt=\(mutation.deletedAt ?? "nil")",
    ]
      .joined(separator: " ")
  }

  public static func seenDataSummary(_ seenData: [DashboardConversationSeen]) -> String {
    if seenData.isEmpty {
      return "[]"
    }

    return seenData
      .map { item in
        let actor: String
        if let userId = item.userId {
          actor = "user:\(userId)"
        } else if let aiAgentId = item.aiAgentId {
          actor = "ai:\(aiAgentId)"
        } else if let visitorId = item.visitorId {
          actor = "visitor:\(visitorId)"
        } else {
          actor = "unknown"
        }

        return "{actor=\(actor) lastSeenAt=\(item.lastSeenAt)}"
      }
      .joined(separator: ", ")
  }

  public static func rawBodyString(_ data: Data?) -> String {
    guard let data, !data.isEmpty else { return "nil" }
    return String(decoding: data, as: UTF8.self)
  }

  public static func responseString(_ data: Data) -> String {
    guard !data.isEmpty else { return "<empty>" }
    return String(decoding: data, as: UTF8.self)
  }

  private static func iso(_ date: Date) -> String {
    DashboardTimestampParser.internetDateTimeString(from: date)
  }
}
