import Foundation

public enum DashboardUploadScope: Sendable {
  case conversation(organizationId: String, websiteId: String, conversationId: String)
  case user(organizationId: String, websiteId: String, userId: String)
  case contact(organizationId: String, websiteId: String, contactId: String)
  case visitor(organizationId: String, websiteId: String, visitorId: String)
}

extension DashboardUploadScope: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .conversation(let organizationId, let websiteId, let conversationId):
      try container.encode("conversation", forKey: .type)
      try container.encode(organizationId, forKey: .organizationId)
      try container.encode(websiteId, forKey: .websiteId)
      try container.encode(conversationId, forKey: .conversationId)
    case .user(let organizationId, let websiteId, let userId):
      try container.encode("user", forKey: .type)
      try container.encode(organizationId, forKey: .organizationId)
      try container.encode(websiteId, forKey: .websiteId)
      try container.encode(userId, forKey: .userId)
    case .contact(let organizationId, let websiteId, let contactId):
      try container.encode("contact", forKey: .type)
      try container.encode(organizationId, forKey: .organizationId)
      try container.encode(websiteId, forKey: .websiteId)
      try container.encode(contactId, forKey: .contactId)
    case .visitor(let organizationId, let websiteId, let visitorId):
      try container.encode("visitor", forKey: .type)
      try container.encode(organizationId, forKey: .organizationId)
      try container.encode(websiteId, forKey: .websiteId)
      try container.encode(visitorId, forKey: .visitorId)
    }
  }

  private enum CodingKeys: String, CodingKey {
    case type
    case organizationId
    case websiteId
    case conversationId
    case userId
    case contactId
    case visitorId
  }
}

public struct DashboardSignedUploadRequest: Encodable, Sendable {
  public let contentType: String
  public let websiteId: String
  public let scope: DashboardUploadScope
  public var path: String?
  public var fileName: String?
  public var fileExtension: String?
  public var useCdn: Bool?
  public var expiresInSeconds: Int?

  public init(
    contentType: String,
    websiteId: String,
    scope: DashboardUploadScope,
    path: String? = nil,
    fileName: String? = nil,
    fileExtension: String? = nil,
    useCdn: Bool? = nil,
    expiresInSeconds: Int? = nil
  ) {
    self.contentType = contentType
    self.websiteId = websiteId
    self.scope = scope
    self.path = path
    self.fileName = fileName
    self.fileExtension = fileExtension
    self.useCdn = useCdn
    self.expiresInSeconds = expiresInSeconds
  }
}

public struct DashboardSignedUploadResponse: Decodable, Hashable, Sendable {
  public let uploadURL: URL
  public let key: String
  public let bucket: String
  public let expiresAt: String
  public let contentType: String
  public let publicURL: URL

  public enum CodingKeys: String, CodingKey {
    case uploadURL = "uploadUrl"
    case key
    case bucket
    case expiresAt
    case contentType
    case publicURL = "publicUrl"
  }
}
