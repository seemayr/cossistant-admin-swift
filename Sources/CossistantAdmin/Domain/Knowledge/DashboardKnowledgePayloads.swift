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

public extension DashboardURLKnowledgePayload {
  var dashboardJSONValue: JSONValue {
    var object: [String: JSONValue] = [
      "markdown": .string(markdown),
      "headings": .array(headings.map { heading in
        .object([
          "level": .number(Double(heading.level)),
          "text": .string(heading.text),
        ])
      }),
      "links": .array(links.map { .string($0.absoluteString) }),
      "images": .array(images.map { image in
        .object([
          "src": .string(image.src.absoluteString),
          "alt": image.alt.map(JSONValue.string) ?? .null,
        ])
      }),
    ]

    if let estimatedTokens {
      object["estimatedTokens"] = .number(Double(estimatedTokens))
    }

    return .object(object)
  }
}

public struct DashboardFAQKnowledgePayload: Codable, Hashable, Sendable {
  public var question: String
  public var answer: String
  public var categories: [String]
  public var relatedQuestions: [String]
}

public extension DashboardFAQKnowledgePayload {
  var dashboardJSONValue: JSONValue {
    .object([
      "question": .string(question),
      "answer": .string(answer),
      "categories": .array(categories.map(JSONValue.string)),
      "relatedQuestions": .array(relatedQuestions.map(JSONValue.string)),
    ])
  }
}

public struct DashboardArticleKnowledgePayload: Codable, Hashable, Sendable {
  public var title: String
  public var summary: String?
  public var markdown: String
  public var keywords: [String]
  public var heroImage: DashboardKnowledgeImage?
}

public extension DashboardArticleKnowledgePayload {
  var dashboardJSONValue: JSONValue {
    var object: [String: JSONValue] = [
      "title": .string(title),
      "summary": summary.map(JSONValue.string) ?? .null,
      "markdown": .string(markdown),
      "keywords": .array(keywords.map(JSONValue.string)),
    ]

    if let heroImage {
      object["heroImage"] = .object([
        "src": .string(heroImage.src.absoluteString),
        "alt": heroImage.alt.map(JSONValue.string) ?? .null,
      ])
    }

    return .object(object)
  }
}
