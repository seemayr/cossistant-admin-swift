import Foundation

public extension CossistantAPIClient {
  func listKnowledge(
    page: Int = 1,
    limit: Int = 20,
    type: DashboardKnowledgeType? = nil,
    aiAgentFilter: DashboardKnowledgeAIAgentFilter,
    isIncluded: DashboardKnowledgeIncludedFilter = .all,
    linkSourceID: String? = nil
  ) async throws -> DashboardKnowledgeListResponse {
    var queryItems = [
      URLQueryItem(name: "page", value: String(page)),
      URLQueryItem(name: "limit", value: String(limit)),
    ]

    if let type {
      queryItems.append(URLQueryItem(name: "type", value: type.rawValue))
    }

    if let aiAgentQueryValue = aiAgentFilter.queryValue,
       !aiAgentQueryValue.isEmpty {
      queryItems.append(URLQueryItem(name: "aiAgentId", value: aiAgentQueryValue))
    }

    if let isIncludedValue = isIncluded.queryValue {
      queryItems.append(URLQueryItem(name: "isIncluded", value: isIncludedValue))
    }

    if let linkSourceID, !linkSourceID.isEmpty {
      queryItems.append(URLQueryItem(name: "linkSourceId", value: linkSourceID))
    }

    print(
      """
      [KnowledgeAPI] listKnowledge \
      page=\(page) \
      limit=\(limit) \
      type=\(type?.rawValue ?? "nil") \
      aiAgentFilter=\(debugDescription(for: aiAgentFilter)) \
      isIncluded=\(isIncluded.rawValue) \
      linkSourceId=\(linkSourceID ?? "nil")
      """
    )

    let response: DashboardKnowledgeListResponse = try await request(path: "knowledge", queryItems: queryItems)
    let itemSummary = response.items
      .prefix(5)
      .map { item in
        "\(item.id):\(item.type.rawValue):\(item.titleText)"
      }
      .joined(separator: " | ")

    print(
      """
      [KnowledgeAPI] listKnowledge response \
      items=\(response.items.count) \
      total=\(response.pagination.total) \
      page=\(response.pagination.page) \
      hasMore=\(response.pagination.hasMore) \
      sample=\(itemSummary.isEmpty ? "none" : itemSummary)
      """
    )

    return response
  }

  func listKnowledge(
    page: Int = 1,
    limit: Int = 20,
    type: DashboardKnowledgeType? = nil,
    aiAgentID: String? = nil,
    isIncluded: DashboardKnowledgeIncludedFilter = .all,
    linkSourceID: String? = nil
  ) async throws -> DashboardKnowledgeListResponse {
    let aiAgentFilter: DashboardKnowledgeAIAgentFilter = if let aiAgentID {
      .specific(aiAgentID)
    } else {
      .all
    }

    return try await listKnowledge(
      page: page,
      limit: limit,
      type: type,
      aiAgentFilter: aiAgentFilter,
      isIncluded: isIncluded,
      linkSourceID: linkSourceID
    )
  }

  func fetchKnowledge(id: String) async throws -> DashboardKnowledge {
    try await request(path: "knowledge/\(id)")
  }

  func createKnowledge(_ draft: DashboardKnowledgeDraft) async throws -> DashboardKnowledge {
    try await request(method: "POST", path: "knowledge", body: draft)
  }

  func updateKnowledge(
    id: String,
    draft: DashboardKnowledgeDraft
  ) async throws -> DashboardKnowledge {
    try await request(method: "PATCH", path: "knowledge/\(id)", body: draft)
  }

  func deleteKnowledge(id: String) async throws {
    let _: EmptyResponse = try await request(method: "DELETE", path: "knowledge/\(id)")
  }

  private func debugDescription(for filter: DashboardKnowledgeAIAgentFilter) -> String {
    switch filter {
    case .all:
      return "all"
    case .shared:
      return "shared"
    case .specific(let id):
      return "specific(\(id))"
    }
  }
}
