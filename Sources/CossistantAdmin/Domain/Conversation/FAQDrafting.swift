import Foundation

public struct FAQDraft: Hashable, Sendable {
  public static let targetChunkSize = 1_000
  public static let chunkOverlap = 200
  public static let recommendedSingleChunkBudget = 900

  public var question = ""
  public var categoriesText = ""
  public var relatedQuestionsText = ""
  public var answer = ""

  public var normalizedQuestion: String {
    question.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  public var normalizedAnswer: String {
    answer.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  public var normalizedCategories: [String] {
    categoriesText
      .split(whereSeparator: { $0 == "," || $0 == "\n" || $0 == ";" })
      .map {
        $0.trimmingCharacters(in: .whitespacesAndNewlines)
      }
      .filter { !$0.isEmpty }
  }

  public var normalizedRelatedQuestions: [String] {
    relatedQuestionsText
      .split(separator: "\n", omittingEmptySubsequences: false)
      .map {
        $0.trimmingCharacters(in: .whitespacesAndNewlines)
      }
      .filter { !$0.isEmpty }
  }

  public var hasMeaningfulContent: Bool {
    !normalizedQuestion.isEmpty
      || !normalizedAnswer.isEmpty
      || !normalizedCategories.isEmpty
      || !normalizedRelatedQuestions.isEmpty
  }

  public var questionCharacterCount: Int {
    normalizedQuestion.count
  }

  public var answerCharacterCount: Int {
    normalizedAnswer.count
  }

  public var relatedQuestionsCharacterCount: Int {
    normalizedRelatedQuestions.joined(separator: "\n").count
  }

  public var categoriesCharacterCount: Int {
    normalizedCategories.joined(separator: ", ").count
  }

  public var embeddedTrainingCharacterCount: Int {
    guard !normalizedQuestion.isEmpty || !normalizedAnswer.isEmpty else {
      return 0
    }

    return 3 + normalizedQuestion.count + 4 + normalizedAnswer.count
  }

  public var embeddedTrainingText: String {
    guard embeddedTrainingCharacterCount > 0 else { return "" }
    return "Q: \(normalizedQuestion)\n\nA: \(normalizedAnswer)"
  }

  public var estimatedChunkCount: Int {
    let count = embeddedTrainingCharacterCount
    guard count > 0 else { return 0 }
    guard count > Self.targetChunkSize else { return 1 }

    let stride = Self.targetChunkSize - Self.chunkOverlap
    let overflow = count - Self.targetChunkSize
    return 1 + Int(ceil(Double(overflow) / Double(stride)))
  }

  public var chunkStatusLabel: String {
    let embeddedCount = embeddedTrainingCharacterCount

    guard embeddedCount > 0 else { return "No embedded text yet" }
    if embeddedCount <= Self.recommendedSingleChunkBudget {
      return "Ideal single chunk"
    }
    if embeddedCount <= Self.targetChunkSize {
      return "Single chunk, near split threshold"
    }
    return "\(estimatedChunkCount) chunks estimated"
  }

  public var categoriesDisplayText: String {
    normalizedCategories.joined(separator: ", ")
  }

  public var relatedQuestionsDisplayText: String {
    normalizedRelatedQuestions.joined(separator: "\n")
  }

  public init(
    question: String = "",
    categoriesText: String = "",
    relatedQuestionsText: String = "",
    answer: String = ""
  ) {
    self.question = question
    self.categoriesText = categoriesText
    self.relatedQuestionsText = relatedQuestionsText
    self.answer = answer
  }

  public init(payload: FAQDraftModelPayload) {
    self.init(
      question: payload.question,
      categoriesText: payload.categories.joined(separator: ", "),
      relatedQuestionsText: payload.relatedQuestions.joined(separator: "\n"),
      answer: payload.answer
    )
  }
}

public struct FAQDraftSuggestion: Hashable, Sendable {
  public let draft: FAQDraft
  public let notes: String?
  public let generatedAt: Date
  public let sourceConversationId: String?
  public let sourceConversationTitle: String?
  public let sourceMessageCount: Int?

  public init(
    draft: FAQDraft,
    notes: String? = nil,
    generatedAt: Date = .now,
    sourceConversationId: String? = nil,
    sourceConversationTitle: String? = nil,
    sourceMessageCount: Int? = nil
  ) {
    self.draft = draft
    self.notes = FAQTextNormalization.nilIfEmpty(notes)
    self.generatedAt = generatedAt
    self.sourceConversationId = sourceConversationId
    self.sourceConversationTitle = sourceConversationTitle
    self.sourceMessageCount = sourceMessageCount
  }
}

public struct FAQDraftModelPayload: Codable, Hashable, Sendable {
  public let question: String
  public let categories: [String]
  public let relatedQuestions: [String]
  public let answer: String
  public let notes: String?

  public var normalized: FAQDraftModelPayload {
    FAQDraftModelPayload(
      question: question.trimmingCharacters(in: .whitespacesAndNewlines),
      categories: categories.normalizedDistinctItems,
      relatedQuestions: relatedQuestions.normalizedDistinctItems,
      answer: answer.trimmingCharacters(in: .whitespacesAndNewlines),
      notes: FAQTextNormalization.nilIfEmpty(notes)
    )
  }
}

public extension String {
  var jsonQuoted: String {
    let data = try? JSONEncoder().encode(self)
    guard let data, let string = String(data: data, encoding: .utf8) else {
      return "\"\""
    }
    return string
  }

  var strippingCodeFenceIfPresent: String {
    let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.hasPrefix("```") else { return trimmed }

    let lines = trimmed.components(separatedBy: "\n")
    guard lines.count >= 3 else { return trimmed }

    let body = lines.dropFirst().dropLast().joined(separator: "\n")
    return body.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}

private enum FAQTextNormalization {
  static func nilIfEmpty(_ value: String?) -> String? {
    guard let value else { return nil }
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }
}

public extension Array where Element == String {
  var jsonArrayLiteral: String {
    let data = try? JSONEncoder().encode(self)
    guard let data, let string = String(data: data, encoding: .utf8) else {
      return "[]"
    }
    return string
  }

  var normalizedDistinctItems: [String] {
    var seen = Set<String>()
    var result: [String] = []

    for item in self {
      let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty else { continue }

      let key = trimmed.localizedLowercase
      guard seen.insert(key).inserted else { continue }
      result.append(trimmed)
    }

    return result
  }
}
