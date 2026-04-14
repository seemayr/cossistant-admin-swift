import Foundation

public struct DashboardVisitor: Identifiable, Decodable, Hashable, Sendable {
  public let id: String
  public let browser: String?
  public let browserVersion: String?
  public let os: String?
  public let osVersion: String?
  public let device: String?
  public let deviceType: String?
  public let ip: String?
  public let city: String?
  public let region: String?
  public let country: String?
  public let countryCode: String?
  public let latitude: Double?
  public let longitude: Double?
  public let language: String?
  public let timezone: String?
  public let screenResolution: String?
  public let viewport: String?
  public let createdAt: String
  public let updatedAt: String
  public let lastSeenAt: String?
  public let websiteId: String
  public let organizationId: String
  public let blockedAt: String?
  public let blockedByUserId: String?
  public let isBlocked: Bool
  public let attribution: JSONValue?
  public let currentPage: JSONValue?
  public let contact: DashboardContact?
}

public struct DashboardVisitorUpdateRequest: Encodable, Sendable {
  public var browser: String?
  public var browserVersion: String?
  public var os: String?
  public var osVersion: String?
  public var device: String?
  public var deviceType: String?
  public var ip: String?
  public var city: String?
  public var region: String?
  public var country: String?
  public var countryCode: String?
  public var latitude: Double?
  public var longitude: Double?
  public var language: String?
  public var timezone: String?
  public var screenResolution: String?
  public var viewport: String?
  public var attribution: JSONValue?
  public var currentPage: JSONValue?

  public init(
    browser: String? = nil,
    browserVersion: String? = nil,
    os: String? = nil,
    osVersion: String? = nil,
    device: String? = nil,
    deviceType: String? = nil,
    ip: String? = nil,
    city: String? = nil,
    region: String? = nil,
    country: String? = nil,
    countryCode: String? = nil,
    latitude: Double? = nil,
    longitude: Double? = nil,
    language: String? = nil,
    timezone: String? = nil,
    screenResolution: String? = nil,
    viewport: String? = nil,
    attribution: JSONValue? = nil,
    currentPage: JSONValue? = nil
  ) {
    self.browser = browser
    self.browserVersion = browserVersion
    self.os = os
    self.osVersion = osVersion
    self.device = device
    self.deviceType = deviceType
    self.ip = ip
    self.city = city
    self.region = region
    self.country = country
    self.countryCode = countryCode
    self.latitude = latitude
    self.longitude = longitude
    self.language = language
    self.timezone = timezone
    self.screenResolution = screenResolution
    self.viewport = viewport
    self.attribution = attribution
    self.currentPage = currentPage
  }
}

public struct DashboardVisitorMetadataUpdateRequest: Encodable, Sendable {
  public let metadata: DashboardMetadata
}
