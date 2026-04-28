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

  public init(
    markdown: String,
    headings: [DashboardKnowledgeHeading] = [],
    links: [URL] = [],
    images: [DashboardKnowledgeImage] = [],
    estimatedTokens: Int? = nil
  ) {
    self.markdown = markdown
    self.headings = headings
    self.links = links
    self.images = images
    self.estimatedTokens = estimatedTokens
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.markdown = try container.decode(String.self, forKey: .markdown)
    self.headings = try container.decodeIfPresent([DashboardKnowledgeHeading].self, forKey: .headings) ?? []
    self.links = try container.decodeIfPresent([URL].self, forKey: .links) ?? []
    self.images = try container.decodeIfPresent([DashboardKnowledgeImage].self, forKey: .images) ?? []
    self.estimatedTokens = try container.decodeIfPresent(Int.self, forKey: .estimatedTokens)
  }

  private enum CodingKeys: String, CodingKey {
    case markdown
    case headings
    case links
    case images
    case estimatedTokens
  }
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

  public init(
    question: String,
    answer: String,
    categories: [String] = [],
    relatedQuestions: [String] = []
  ) {
    self.question = question
    self.answer = answer
    self.categories = categories
    self.relatedQuestions = relatedQuestions
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.question = try container.decode(String.self, forKey: .question)
    self.answer = try container.decode(String.self, forKey: .answer)
    self.categories = try container.decodeIfPresent([String].self, forKey: .categories) ?? []
    self.relatedQuestions = try container.decodeIfPresent([String].self, forKey: .relatedQuestions) ?? []
  }

  private enum CodingKeys: String, CodingKey {
    case question
    case answer
    case categories
    case relatedQuestions
  }
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

  public init(
    title: String,
    summary: String? = nil,
    markdown: String,
    keywords: [String] = [],
    heroImage: DashboardKnowledgeImage? = nil
  ) {
    self.title = title
    self.summary = summary
    self.markdown = markdown
    self.keywords = keywords
    self.heroImage = heroImage
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.title = try container.decode(String.self, forKey: .title)
    self.summary = try container.decodeIfPresent(String.self, forKey: .summary)
    self.markdown = try container.decode(String.self, forKey: .markdown)
    self.keywords = try container.decodeIfPresent([String].self, forKey: .keywords) ?? []
    self.heroImage = try container.decodeIfPresent(DashboardKnowledgeImage.self, forKey: .heroImage)
  }

  private enum CodingKeys: String, CodingKey {
    case title
    case summary
    case markdown
    case keywords
    case heroImage
  }
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
