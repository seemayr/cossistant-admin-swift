import Foundation

public struct DashboardAIAgent: Identifiable, Decodable, Hashable, Sendable {
  public let id: String
  public let name: String
  public let image: URL?
  public let description: String?
  public let basePrompt: String
  public let model: String
  public let temperature: Double?
  public let maxOutputTokens: Int?
  public let isActive: Bool
  public let lastUsedAt: String?
  public let usageCount: Int
  public let goals: [String]?
  public let createdAt: String
  public let updatedAt: String
  public let onboardingCompletedAt: String?

  public var displayName: String {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmedName.isEmpty ? "AI agent" : trimmedName
  }

  public var createdAtDate: Date? {
    DashboardTimestampParser.date(from: createdAt)
  }

  public var updatedAtDate: Date? {
    DashboardTimestampParser.date(from: updatedAt)
  }

  public var lastUsedAtDate: Date? {
    guard let lastUsedAt else { return nil }
    return DashboardTimestampParser.date(from: lastUsedAt)
  }

  public var onboardingCompletedAtDate: Date? {
    guard let onboardingCompletedAt else { return nil }
    return DashboardTimestampParser.date(from: onboardingCompletedAt)
  }
}

public enum DashboardAIAgentTrainingPublicStatus: String, Decodable, Sendable {
  case outOfDate = "out_of_date"
  case trained
  case trainingOngoing = "training_ongoing"
}

public enum DashboardAIAgentTrainingInternalStatus: String, Decodable, Sendable {
  case idle
  case pending
  case training
  case completed
  case failed
}

public struct DashboardAIAgentTrainingStatus: Decodable, Hashable, Sendable {
  public let aiAgentId: String
  public let status: DashboardAIAgentTrainingPublicStatus
  public let internalStatus: DashboardAIAgentTrainingInternalStatus
  public let progress: Int
  public let updatedSourcesCount: Int
  public let canTrainAt: String?
  public let lastTrainedAt: String?
  public let trainingStartedAt: String?
  public let trainedItemsCount: Int?
  public let lastError: String?

  public var canTrainAtDate: Date? {
    guard let canTrainAt else { return nil }
    return DashboardTimestampParser.date(from: canTrainAt)
  }

  public var lastTrainedAtDate: Date? {
    guard let lastTrainedAt else { return nil }
    return DashboardTimestampParser.date(from: lastTrainedAt)
  }

  public var trainingStartedAtDate: Date? {
    guard let trainingStartedAt else { return nil }
    return DashboardTimestampParser.date(from: trainingStartedAt)
  }

  public var isTrainingInProgress: Bool {
    status == .trainingOngoing
  }
}

public struct DashboardAIAgentTrainingJob: Decodable, Hashable, Sendable {
  public let aiAgentId: String
  public let jobId: String
  public let status: DashboardAIAgentTrainingPublicStatus
  public let internalStatus: DashboardAIAgentTrainingInternalStatus
  public let progress: Int
}
