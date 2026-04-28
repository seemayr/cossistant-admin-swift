import Foundation

public enum DashboardKnowledgeEditorError: LocalizedError {
  case invalidURL(String)
  case invalidEstimatedTokens
  case invalidMetadata
  case missingRequiredField(String)

  public var errorDescription: String? {
    switch self {
    case .invalidURL(let label):
      "\(label) must be a valid absolute URL."
    case .invalidEstimatedTokens:
      "Estimated tokens must be a non-negative whole number."
    case .invalidMetadata:
      "Metadata must be a valid JSON object."
    case .missingRequiredField(let label):
      "\(label) is required."
    }
  }
}

public struct DashboardKnowledgeEditorDraft: Equatable, Sendable {
  public var id: String?
  public var type: DashboardKnowledgeType
  public var originalPayload: JSONValue?
  public var aiAgentID = ""
  public var sourceURL = ""
  public var sourceTitle = ""
  public var origin = "manual"
  public var metadataText = ""
  public var faqQuestion = ""
  public var faqAnswer = ""
  public var faqCategoriesText = ""
  public var faqRelatedQuestionsText = ""
  public var articleTitle = ""
  public var articleSummary = ""
  public var articleMarkdown = ""
  public var articleKeywordsText = ""
  public var articleHeroImageURL = ""
  public var articleHeroImageAlt = ""
  public var urlMarkdown = ""
  public var urlHeadingsText = ""
  public var urlLinksText = ""
  public var urlImagesText = ""
  public var urlEstimatedTokensText = ""

  public init(type: DashboardKnowledgeType) {
    self.type = type
  }

  public init(item: DashboardKnowledge) {
    id = item.id
    type = item.type
    originalPayload = item.payload
    aiAgentID = item.aiAgentId ?? ""
    sourceURL = item.sourceUrl?.absoluteString ?? ""
    sourceTitle = item.sourceTitle ?? ""
    origin = item.origin
    metadataText = item.metadata?.dashboardPrettyPrintedJSONString ?? ""

    if let payload = item.faqPayload {
      faqQuestion = payload.question
      faqAnswer = payload.answer
      faqCategoriesText = payload.categories.joined(separator: ", ")
      faqRelatedQuestionsText = payload.relatedQuestions.joined(separator: "\n")
    }

    if let payload = item.articlePayload {
      articleTitle = payload.title
      articleSummary = payload.summary ?? ""
      articleMarkdown = payload.markdown
      articleKeywordsText = payload.keywords.joined(separator: ", ")
      articleHeroImageURL = payload.heroImage?.src.absoluteString ?? ""
      articleHeroImageAlt = payload.heroImage?.alt ?? ""
    } else if item.type == .article {
      articleTitle = item.payload.dashboardStringValue(forKey: "title")
        ?? item.sourceTitle
        ?? item.titleText
      articleSummary = item.payload.dashboardStringValue(forKey: "summary")
        ?? item.payload.dashboardStringValue(forKey: "description")
        ?? ""
      articleMarkdown = item.payload.dashboardStringValue(forKey: "markdown")
        ?? item.payload.dashboardStringValue(forKey: "content")
        ?? articleSummary
      articleKeywordsText = item.payload.dashboardStringArrayValue(forKey: "keywords").joined(separator: ", ")
    }

    if let payload = item.urlPayload {
      urlMarkdown = payload.markdown
      urlHeadingsText = payload.headings
        .map { "\($0.level)|\($0.text)" }
        .joined(separator: "\n")
      urlLinksText = payload.links
        .map(\.absoluteString)
        .joined(separator: "\n")
      urlImagesText = payload.images
        .map { image in
          let alt = image.alt ?? ""
          return "\(image.src.absoluteString)|\(alt)"
        }
        .joined(separator: "\n")
      if let estimatedTokens = payload.estimatedTokens {
        urlEstimatedTokensText = String(estimatedTokens)
      }
    } else if item.type == .url {
      urlMarkdown = item.payload.dashboardStringValue(forKey: "markdown")
        ?? item.payload.dashboardStringValue(forKey: "content")
        ?? ""
      urlEstimatedTokensText = item.payload.dashboardNumberValue(forKey: "estimatedTokens").map { value in
        if value.rounded(.towardZero) == value {
          return String(Int(value))
        }
        return String(value)
      } ?? ""
    }
  }

  public var editorTitle: String {
    if id == nil {
      return "New \(resolvedRequestType.label)"
    }

    return "Edit \(resolvedRequestType.label)"
  }

  public func makeRequest() throws -> DashboardKnowledgeDraft {
    let requestType = resolvedRequestType
    return DashboardKnowledgeDraft(
      aiAgentId: aiAgentID.dashboardNilIfEmpty,
      type: requestType,
      sourceUrl: try parsedURL(sourceURL, label: "Source URL"),
      sourceTitle: sourceTitle.dashboardNilIfEmpty ?? inferredSourceTitle(for: requestType),
      origin: origin.dashboardTrimmedNonEmpty(fallback: "manual"),
      payload: try payloadValue(for: requestType),
      metadata: try parsedMetadata()
    )
  }

  private var resolvedRequestType: DashboardKnowledgeType {
    if faqQuestion.dashboardNilIfEmpty != nil,
       faqAnswer.dashboardNilIfEmpty != nil {
      return .faq
    }

    return type
  }

  public var editorPayloadType: DashboardKnowledgeType {
    resolvedRequestType
  }

  public var editorTypeLabel: String {
    resolvedRequestType.label
  }

  private func inferredSourceTitle(for requestType: DashboardKnowledgeType) -> String? {
    switch requestType {
    case .faq:
      faqQuestion.dashboardNilIfEmpty
    case .article:
      articleTitle.dashboardNilIfEmpty
    case .url:
      nil
    }
  }

  private func payloadValue(for requestType: DashboardKnowledgeType) throws -> JSONValue {
    switch requestType {
    case .faq:
      guard let question = faqQuestion.dashboardNilIfEmpty else {
        throw DashboardKnowledgeEditorError.missingRequiredField("Question")
      }
      guard let answer = faqAnswer.dashboardNilIfEmpty else {
        throw DashboardKnowledgeEditorError.missingRequiredField("Answer")
      }
      var object = originalPayloadObject
      object["question"] = .string(question)
      object["answer"] = .string(answer)
      object["categories"] = .array(faqCategoriesText.dashboardCommaSeparatedValues.map(JSONValue.string))
      object["relatedQuestions"] = .array(
        faqRelatedQuestionsText.dashboardLineSeparatedValues.map(JSONValue.string)
      )

      if id != nil {
        object["title"] = .string(question)
        object["markdown"] = .string(answer)
      }
      return .object(object)
    case .article:
      guard let title = articleTitle.dashboardNilIfEmpty
        ?? originalPayload?.dashboardStringValue(forKey: "title")
        ?? sourceTitle.dashboardNilIfEmpty else {
        throw DashboardKnowledgeEditorError.missingRequiredField("Title")
      }
      guard let markdown = articleMarkdown.dashboardNilIfEmpty
        ?? originalPayload?.dashboardStringValue(forKey: "markdown")
        ?? originalPayload?.dashboardStringValue(forKey: "content")
        ?? articleSummary.dashboardNilIfEmpty else {
        throw DashboardKnowledgeEditorError.missingRequiredField("Markdown")
      }

      var object = originalPayloadObject
      object["title"] = .string(title)
      object["markdown"] = .string(markdown)
      object["keywords"] = .array(articleKeywordsText.dashboardCommaSeparatedValues.map(JSONValue.string))
      object["summary"] = articleSummary.dashboardNilIfEmpty.map(JSONValue.string) ?? .null

      if let heroImageURL = try parsedURL(articleHeroImageURL, label: "Hero image URL") {
        object["heroImage"] = .object([
          "src": .string(heroImageURL.absoluteString),
          "alt": articleHeroImageAlt.dashboardNilIfEmpty.map(JSONValue.string) ?? .null,
        ])
      }

      return .object(object)
    case .url:
      guard let markdown = urlMarkdown.dashboardNilIfEmpty
        ?? originalPayload?.dashboardStringValue(forKey: "markdown")
        ?? originalPayload?.dashboardStringValue(forKey: "content") else {
        throw DashboardKnowledgeEditorError.missingRequiredField("Markdown")
      }

      var object = originalPayloadObject
      object["markdown"] = .string(markdown)
      object["headings"] = .array(try parsedHeadings().map { heading in
          .object([
            "level": .number(Double(heading.level)),
            "text": .string(heading.text),
          ])
        })
      object["links"] = .array(try parsedLinks().map { .string($0.absoluteString) })
      object["images"] = .array(try parsedImages().map { image in
          .object([
            "src": .string(image.src.absoluteString),
            "alt": image.alt.map(JSONValue.string) ?? .null,
          ])
        })

      if !urlEstimatedTokensText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        guard let estimatedTokens = Int(urlEstimatedTokensText),
              estimatedTokens >= 0 else {
          throw DashboardKnowledgeEditorError.invalidEstimatedTokens
        }
        object["estimatedTokens"] = .number(Double(estimatedTokens))
      }

      return .object(object)
    }
  }

  private var originalPayloadObject: [String: JSONValue] {
    guard case .object(let object)? = originalPayload else { return [:] }
    return object
  }

  private func parsedMetadata() throws -> DashboardMetadata? {
    let trimmed = metadataText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }
    guard let data = trimmed.data(using: .utf8),
          let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      throw DashboardKnowledgeEditorError.invalidMetadata
    }
    return try object.reduce(into: DashboardMetadata()) { result, entry in
      result[entry.key] = try JSONValue.dashboardValue(from: entry.value)
    }
  }

  private func parsedHeadings() throws -> [DashboardKnowledgeHeading] {
    try urlHeadingsText.dashboardLineSeparatedValues.compactMap { line in
      let segments = line.split(separator: "|", maxSplits: 1).map(String.init)
      guard segments.count == 2, let level = Int(segments[0]), (1...6).contains(level) else {
        throw DashboardKnowledgeEditorError.missingRequiredField(
          "Each heading must use `level|text` with a level from 1 to 6"
        )
      }
      let text = segments[1].trimmingCharacters(in: .whitespacesAndNewlines)
      guard !text.isEmpty else {
        throw DashboardKnowledgeEditorError.missingRequiredField("Heading text")
      }
      return DashboardKnowledgeHeading(level: level, text: text)
    }
  }

  private func parsedLinks() throws -> [URL] {
    try urlLinksText.dashboardLineSeparatedValues.map {
      guard let url = URL(string: $0), url.scheme != nil, url.host != nil else {
        throw DashboardKnowledgeEditorError.invalidURL("Page link")
      }
      return url
    }
  }

  private func parsedImages() throws -> [DashboardKnowledgeImage] {
    try urlImagesText.dashboardLineSeparatedValues.map { line in
      let segments = line.split(separator: "|", maxSplits: 1).map(String.init)
      guard let src = segments.first,
            let url = URL(string: src),
            url.scheme != nil,
            url.host != nil else {
        throw DashboardKnowledgeEditorError.invalidURL("Image URL")
      }
      let alt = segments.count > 1 ? segments[1].dashboardNilIfEmpty : nil
      return DashboardKnowledgeImage(src: url, alt: alt)
    }
  }

  private func parsedURL(_ value: String, label: String) throws -> URL? {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }
    guard let url = URL(string: trimmed), url.scheme != nil, url.host != nil else {
      throw DashboardKnowledgeEditorError.invalidURL(label)
    }
    return url
  }
}

public extension DashboardKnowledgeEditorDraft {
  static func blank(type: DashboardKnowledgeType) -> Self {
    DashboardKnowledgeEditorDraft(type: type)
  }
}

public extension String {
  var dashboardNilIfEmpty: String? {
    let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }

  func dashboardTrimmedNonEmpty(fallback: String) -> String {
    dashboardNilIfEmpty ?? fallback
  }

  var dashboardCommaSeparatedValues: [String] {
    split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
  }

  var dashboardLineSeparatedValues: [String] {
    split(whereSeparator: \.isNewline)
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
  }
}
