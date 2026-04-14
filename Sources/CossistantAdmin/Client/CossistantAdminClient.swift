import Foundation

public final class CossistantAdminClient {
  public let configuration: DashboardConfiguration
  private let session: URLSession
  private let transport: CossistantAPIClient

  public init(
    configuration: DashboardConfiguration,
    session: URLSession = .shared
  ) {
    self.configuration = configuration
    self.session = session
    self.transport = CossistantAPIClient(
      configuration: configuration,
      session: session
    )
  }

  public var bootstrap: BootstrapAPI {
    BootstrapAPI(transport: transport)
  }

  public var conversations: ConversationsAPI {
    ConversationsAPI(transport: transport)
  }

  public var contacts: ContactsAPI {
    ContactsAPI(transport: transport)
  }

  public var knowledge: KnowledgeAPI {
    KnowledgeAPI(transport: transport)
  }

  public var uploads: UploadsAPI {
    UploadsAPI(transport: transport)
  }

  public var visitors: VisitorsAPI {
    VisitorsAPI(transport: transport)
  }

  public func makeRealtimeClient(
    websiteID: String,
    organizationID: String?,
    onConnectionStateChange: @escaping @MainActor @Sendable (DashboardRealtimeConnectionState) -> Void,
    onEvent: @escaping @MainActor @Sendable (DashboardRealtimeEvent) -> Void
  ) throws -> CossistantRealtimeClient {
    guard configuration.trimmedPrivateAPIKey.hasPrefix("sk_"),
          let baseURL = configuration.apiBaseURL,
          var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
      throw CossistantAPIError.invalidBaseURL
    }

    switch components.scheme {
    case "https":
      components.scheme = "wss"
    case "http":
      components.scheme = "ws"
    default:
      throw CossistantAPIError.invalidBaseURL
    }

    let trimmedPath = components.path.replacingOccurrences(of: "/v1", with: "")
    components.path = "\(trimmedPath)/ws".replacingOccurrences(of: "//", with: "/")
    components.queryItems = [
      URLQueryItem(name: "token", value: configuration.trimmedPrivateAPIKey),
      URLQueryItem(name: "websiteId", value: websiteID),
    ]

    guard let webSocketURL = components.url else {
      throw CossistantAPIError.invalidBaseURL
    }

    return CossistantRealtimeClient(
      webSocketURL: webSocketURL,
      websiteID: websiteID,
      organizationID: organizationID,
      session: session,
      onConnectionStateChange: onConnectionStateChange,
      onEvent: onEvent
    )
  }
}

public extension CossistantAdminClient {
  public struct BootstrapAPI {
    fileprivate let transport: CossistantAPIClient

    public func fetchWorkspace(limit: Int = 100) async throws -> WorkspaceBootstrap {
      try await transport.fetchBootstrap(limit: limit)
    }
  }

  public struct ConversationsAPI {
    fileprivate let transport: CossistantAPIClient

    public func fetchInbox(limit: Int = 100, cursor: String?) async throws -> DashboardConversationPage {
      try await transport.fetchInbox(limit: limit, cursor: cursor)
    }

    public func fetchConversation(id: DashboardConversation.ID) async throws -> DashboardConversationDetail {
      try await transport.fetchConversation(id: id)
    }

    public func fetchTimeline(
      conversationID: DashboardConversation.ID,
      limit: Int = 50,
      cursor: String? = nil
    ) async throws -> DashboardTimelinePage {
      try await transport.fetchTimeline(
        conversationID: conversationID,
        limit: limit,
        cursor: cursor
      )
    }

    public func fetchConversationSeenData(
      conversationID: DashboardConversation.ID
    ) async throws -> [DashboardConversationSeen] {
      try await transport.fetchConversationSeenData(conversationID: conversationID)
    }

    public func markConversationRead(
      conversationID: DashboardConversation.ID
    ) async throws -> DashboardConversationMutation {
      try await transport.markConversationRead(conversationID: conversationID)
    }

    public func setConversationTyping(
      conversationID: DashboardConversation.ID,
      payload: DashboardConversationTypingRequest
    ) async throws -> DashboardConversationTypingResponse {
      try await transport.setConversationTyping(
        conversationID: conversationID,
        payload: payload
      )
    }

    public func resolveConversation(
      conversationID: DashboardConversation.ID
    ) async throws -> DashboardConversationMutation {
      try await transport.resolveConversation(conversationID: conversationID)
    }

    public func reopenConversation(
      conversationID: DashboardConversation.ID
    ) async throws -> DashboardConversationMutation {
      try await transport.reopenConversation(conversationID: conversationID)
    }

    public func markConversationSpam(
      conversationID: DashboardConversation.ID
    ) async throws -> DashboardConversationMutation {
      try await transport.markConversationSpam(conversationID: conversationID)
    }

    public func markConversationNotSpam(
      conversationID: DashboardConversation.ID
    ) async throws -> DashboardConversationMutation {
      try await transport.markConversationNotSpam(conversationID: conversationID)
    }

    public func markConversationUnread(
      conversationID: DashboardConversation.ID
    ) async throws -> DashboardConversationMutation {
      try await transport.markConversationUnread(conversationID: conversationID)
    }

    public func archiveConversation(
      conversationID: DashboardConversation.ID
    ) async throws -> DashboardConversationMutation {
      try await transport.archiveConversation(conversationID: conversationID)
    }

    public func unarchiveConversation(
      conversationID: DashboardConversation.ID
    ) async throws -> DashboardConversationMutation {
      try await transport.unarchiveConversation(conversationID: conversationID)
    }

    public func updateConversationTitle(
      conversationID: DashboardConversation.ID,
      title: String?
    ) async throws -> DashboardConversationMutation {
      try await transport.updateConversationTitle(
        conversationID: conversationID,
        title: title
      )
    }

    public func updateConversationMetadata(
      conversationID: DashboardConversation.ID,
      metadata: DashboardMetadata
    ) async throws -> DashboardConversationMutation {
      try await transport.updateConversationMetadata(
        conversationID: conversationID,
        metadata: metadata
      )
    }

    public func joinConversationEscalation(
      conversationID: DashboardConversation.ID
    ) async throws -> DashboardConversationMutation {
      try await transport.joinConversationEscalation(conversationID: conversationID)
    }

    public func pauseConversationAI(
      conversationID: DashboardConversation.ID,
      durationMinutes: Int
    ) async throws -> DashboardConversationMutation {
      try await transport.pauseConversationAI(
        conversationID: conversationID,
        durationMinutes: durationMinutes
      )
    }

    public func resumeConversationAI(
      conversationID: DashboardConversation.ID
    ) async throws -> DashboardConversationMutation {
      try await transport.resumeConversationAI(conversationID: conversationID)
    }

    public func sendTimelineItem(
      _ payload: DashboardSendTimelineItemRequest
    ) async throws -> DashboardTimelineItem {
      try await transport.sendTimelineItem(payload)
    }
  }

  public struct ContactsAPI {
    fileprivate let transport: CossistantAPIClient

    public func listContacts(
      page: Int = 1,
      limit: Int = 20,
      search: String? = nil,
      sortBy: DashboardContactSortBy? = nil,
      sortOrder: DashboardSortOrder? = nil,
      visitorStatus: DashboardContactVisitorStatus = .all
    ) async throws -> DashboardContactListResponse {
      try await transport.listContacts(
        page: page,
        limit: limit,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
        visitorStatus: visitorStatus
      )
    }

    public func fetchContact(id: String) async throws -> DashboardContact {
      try await transport.fetchContact(id: id)
    }

    public func createContact(_ draft: DashboardContactDraft) async throws -> DashboardContact {
      try await transport.createContact(draft)
    }

    public func updateContact(
      id: String,
      draft: DashboardContactDraft
    ) async throws -> DashboardContact {
      try await transport.updateContact(id: id, draft: draft)
    }

    public func updateContactMetadata(
      id: String,
      metadata: DashboardMetadata
    ) async throws -> DashboardContact {
      try await transport.updateContactMetadata(id: id, metadata: metadata)
    }

    public func deleteContact(id: String) async throws {
      try await transport.deleteContact(id: id)
    }

    public func identifyContact(
      _ payload: DashboardIdentifyContactRequest
    ) async throws -> DashboardIdentifyContactResponse {
      try await transport.identifyContact(payload)
    }

    public func createContactOrganization(
      _ draft: DashboardContactOrganizationDraft
    ) async throws -> DashboardContactOrganization {
      try await transport.createContactOrganization(draft)
    }

    public func fetchContactOrganization(id: String) async throws -> DashboardContactOrganization {
      try await transport.fetchContactOrganization(id: id)
    }

    public func updateContactOrganization(
      id: String,
      draft: DashboardContactOrganizationDraft
    ) async throws -> DashboardContactOrganization {
      try await transport.updateContactOrganization(id: id, draft: draft)
    }

    public func deleteContactOrganization(id: String) async throws {
      try await transport.deleteContactOrganization(id: id)
    }
  }

  public struct KnowledgeAPI {
    fileprivate let transport: CossistantAPIClient

    public func listKnowledge(
      page: Int = 1,
      limit: Int = 20,
      type: DashboardKnowledgeType? = nil,
      aiAgentID: String? = nil,
      isIncluded: DashboardKnowledgeIncludedFilter = .all,
      linkSourceID: String? = nil
    ) async throws -> DashboardKnowledgeListResponse {
      try await transport.listKnowledge(
        page: page,
        limit: limit,
        type: type,
        aiAgentID: aiAgentID,
        isIncluded: isIncluded,
        linkSourceID: linkSourceID
      )
    }

    public func fetchKnowledge(id: String) async throws -> DashboardKnowledge {
      try await transport.fetchKnowledge(id: id)
    }

    public func createKnowledge(_ draft: DashboardKnowledgeDraft) async throws -> DashboardKnowledge {
      try await transport.createKnowledge(draft)
    }

    public func updateKnowledge(
      id: String,
      draft: DashboardKnowledgeDraft
    ) async throws -> DashboardKnowledge {
      try await transport.updateKnowledge(id: id, draft: draft)
    }

    public func deleteKnowledge(id: String) async throws {
      try await transport.deleteKnowledge(id: id)
    }
  }

  public struct UploadsAPI {
    fileprivate let transport: CossistantAPIClient

    public func generateUploadURL(
      _ payload: DashboardSignedUploadRequest
    ) async throws -> DashboardSignedUploadResponse {
      try await transport.generateUploadURL(payload)
    }

    public func upload(
      data: Data,
      using signedUpload: DashboardSignedUploadResponse
    ) async throws {
      try await transport.upload(data: data, using: signedUpload)
    }
  }

  public struct VisitorsAPI {
    fileprivate let transport: CossistantAPIClient

    public func fetchVisitor(id: String) async throws -> DashboardVisitor {
      try await transport.fetchVisitor(id: id)
    }

    public func updateVisitor(
      id: String,
      payload: DashboardVisitorUpdateRequest
    ) async throws -> DashboardVisitor {
      try await transport.updateVisitor(id: id, payload: payload)
    }

    public func updateVisitorMetadata(
      visitorID: String,
      metadata: DashboardMetadata
    ) async throws -> DashboardVisitor {
      try await transport.updateVisitorMetadata(
        visitorID: visitorID,
        metadata: metadata
      )
    }
  }
}
