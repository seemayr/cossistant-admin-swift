import Foundation

public extension CossistantAPIClient {
  func fetchAIAgent(id: String) async throws -> DashboardAIAgent {
    try await request(path: "ai-agents/\(id)")
  }

  func fetchAIAgentTrainingStatus(
    id: String
  ) async throws -> DashboardAIAgentTrainingStatus {
    try await request(path: "ai-agents/\(id)/training")
  }

  func startAIAgentTraining(
    id: String
  ) async throws -> DashboardAIAgentTrainingJob {
    try await request(method: "POST", path: "ai-agents/\(id)/training")
  }
}
