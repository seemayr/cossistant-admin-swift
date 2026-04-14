import Foundation

public typealias DashboardMetadata = [String: JSONValue]

public struct DashboardContactListResponse: Decodable, Sendable {
  public let items: [DashboardContactListItem]
  public let page: Int
  public let pageSize: Int
  public let totalCount: Int
}

public struct DashboardContactListItem: Identifiable, Decodable, Hashable, Sendable {
  public let id: String
  public let name: String?
  public let email: String?
  public let image: URL?
  public let createdAt: String
  public let updatedAt: String
  public let visitorCount: Int
  public let lastSeenAt: String?
  public let contactOrganizationId: String?
  public let contactOrganizationName: String?

  public var displayName: String {
    DashboardIdentity.contactDisplayName(
      name: name,
      email: email,
      contactID: id
    )
  }

  public var avatarSeed: String {
    email ?? id
  }

  public var createdAtDate: Date? {
    DashboardTimestampParser.date(from: createdAt)
  }

  public var updatedAtDate: Date? {
    DashboardTimestampParser.date(from: updatedAt)
  }

  public var lastSeenAtDate: Date? {
    DashboardTimestampParser.date(from: lastSeenAt)
  }

  public var createdRelativeText: String {
    DashboardTimestampParser.relativeString(from: createdAt) ?? createdAt
  }

  public var lastSeenRelativeText: String {
    DashboardTimestampParser.relativeString(from: lastSeenAt) ?? "Not seen yet"
  }

  public var createdAbsoluteText: String {
    DashboardTimestampParser.absoluteString(from: createdAt) ?? createdAt
  }

  public var updatedAbsoluteText: String {
    DashboardTimestampParser.absoluteString(from: updatedAt) ?? updatedAt
  }

  public var lastSeenAbsoluteText: String {
    DashboardTimestampParser.absoluteString(from: lastSeenAt) ?? "Not seen yet"
  }
}

public struct DashboardContact: Identifiable, Decodable, Hashable, Sendable {
  public let id: String
  public let externalId: String?
  public let name: String?
  public let email: String?
  public let image: URL?
  public let metadata: DashboardMetadata?
  public let contactOrganizationId: String?
  public let websiteId: String
  public let organizationId: String
  public let userId: String?
  public let createdAt: String
  public let updatedAt: String

  public var displayName: String {
    DashboardIdentity.contactDisplayName(
      name: name,
      email: email,
      contactID: id
    )
  }

  public var avatarSeed: String {
    email ?? id
  }

  public var createdAbsoluteText: String {
    DashboardTimestampParser.absoluteString(from: createdAt) ?? createdAt
  }

  public var updatedAbsoluteText: String {
    DashboardTimestampParser.absoluteString(from: updatedAt) ?? updatedAt
  }
}

public struct DashboardContactDraft: Encodable, Sendable {
  public var externalId: String?
  public var name: String?
  public var email: String?
  public var image: URL?
  public var metadata: DashboardMetadata?
  public var contactOrganizationId: String?

  public init(
    externalId: String? = nil,
    name: String? = nil,
    email: String? = nil,
    image: URL? = nil,
    metadata: DashboardMetadata? = nil,
    contactOrganizationId: String? = nil
  ) {
    self.externalId = externalId
    self.name = name
    self.email = email
    self.image = image
    self.metadata = metadata
    self.contactOrganizationId = contactOrganizationId
  }
}

public struct DashboardContactMetadataUpdateRequest: Encodable, Sendable {
  public let metadata: DashboardMetadata
}

public struct DashboardIdentifyContactRequest: Encodable, Sendable {
  public var id: String?
  public var visitorId: String
  public var externalId: String?
  public var name: String?
  public var email: String?
  public var image: URL?
  public var metadata: DashboardMetadata?
  public var contactOrganizationId: String?

  public init(
    id: String? = nil,
    visitorId: String,
    externalId: String? = nil,
    name: String? = nil,
    email: String? = nil,
    image: URL? = nil,
    metadata: DashboardMetadata? = nil,
    contactOrganizationId: String? = nil
  ) {
    self.id = id
    self.visitorId = visitorId
    self.externalId = externalId
    self.name = name
    self.email = email
    self.image = image
    self.metadata = metadata
    self.contactOrganizationId = contactOrganizationId
  }
}

public struct DashboardIdentifyContactResponse: Decodable, Sendable {
  public let contact: DashboardContact
  public let visitorId: String
}

public struct DashboardContactOrganization: Identifiable, Decodable, Hashable, Sendable {
  public let id: String
  public let name: String
  public let externalId: String?
  public let domain: String?
  public let description: String?
  public let metadata: DashboardMetadata?
  public let websiteId: String
  public let organizationId: String
  public let createdAt: String
  public let updatedAt: String
}

public struct DashboardContactOrganizationDraft: Encodable, Sendable {
  public var name: String?
  public var externalId: String?
  public var domain: String?
  public var description: String?
  public var metadata: DashboardMetadata?

  public init(
    name: String? = nil,
    externalId: String? = nil,
    domain: String? = nil,
    description: String? = nil,
    metadata: DashboardMetadata? = nil
  ) {
    self.name = name
    self.externalId = externalId
    self.domain = domain
    self.description = description
    self.metadata = metadata
  }
}

public enum DashboardContactSortBy: String, CaseIterable, Identifiable, Sendable {
  case name
  case email
  case createdAt
  case updatedAt
  case visitorCount
  case lastSeenAt

  public var id: String { rawValue }

  public var label: String {
    switch self {
    case .name:
      return "Name"
    case .email:
      return "Email"
    case .createdAt:
      return "Created"
    case .updatedAt:
      return "Updated"
    case .visitorCount:
      return "Visit Count"
    case .lastSeenAt:
      return "Last Seen"
    }
  }
}

public enum DashboardSortOrder: String, CaseIterable, Identifiable, Sendable {
  case asc
  case desc

  public var id: String { rawValue }

  public var label: String {
    switch self {
    case .asc:
      return "Ascending"
    case .desc:
      return "Descending"
    }
  }
}

public enum DashboardContactVisitorStatus: String, CaseIterable, Identifiable, Sendable {
  case all
  case withVisitors
  case withoutVisitors

  public var id: String { rawValue }

  public var label: String {
    switch self {
    case .all:
      return "All"
    case .withVisitors:
      return "With Visitors"
    case .withoutVisitors:
      return "Without Visitors"
    }
  }
}
