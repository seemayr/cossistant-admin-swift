import Foundation

public struct DashboardKnowledgeHeading: Codable, Hashable, Sendable {
  public var level: Int
  public var text: String
}

public struct DashboardKnowledgeImage: Codable, Hashable, Sendable {
  public var src: URL
  public var alt: String?
}

public struct DashboardURLKnowledgePayload: Codable, Hashable, Sendable {
  public var markdown: String
  public var headings: [DashboardKnowledgeHeading]
  public var links: [URL]
  public var images: [DashboardKnowledgeImage]
  public var estimatedTokens: Int?
}

public struct DashboardFAQKnowledgePayload: Codable, Hashable, Sendable {
  public var question: String
  public var answer: String
  public var categories: [String]
  public var relatedQuestions: [String]
}

public struct DashboardArticleKnowledgePayload: Codable, Hashable, Sendable {
  public var title: String
  public var summary: String?
  public var markdown: String
  public var keywords: [String]
  public var heroImage: DashboardKnowledgeImage?
}
