import Foundation
import UniformTypeIdentifiers

public struct DashboardComposerAttachment: Identifiable, Hashable, Sendable {
  public let id: UUID
  public let data: Data
  public let fileName: String
  public let contentType: String

  public init(
    id: UUID = UUID(),
    data: Data,
    fileName: String,
    contentType: String
  ) {
    self.id = id
    self.data = data
    self.fileName = fileName
    self.contentType = contentType
  }

  public var isImage: Bool {
    contentType.hasPrefix("image/")
  }

  public var fileSizeBytes: Int {
    data.count
  }

  public var formattedSize: String {
    ByteCountFormatter.string(fromByteCount: Int64(fileSizeBytes), countStyle: .file)
  }
}

public enum DashboardAttachmentValidationError: LocalizedError {
  case fileTooLarge(fileName: String, maxMB: Int)
  case unsupportedType(fileName: String)
  case tooManyFiles(max: Int)
  case unreadableFile(fileName: String)

  public var errorDescription: String? {
    switch self {
    case .fileTooLarge(let fileName, let maxMB):
      "\(fileName) is too large. Maximum size is \(maxMB) MB."
    case .unsupportedType(let fileName):
      "\(fileName) is not a supported file type."
    case .tooManyFiles(let max):
      "You can attach up to \(max) files per message."
    case .unreadableFile(let fileName):
      "Could not read \(fileName)."
    }
  }
}

public enum DashboardUploadConstants {
  public static let maxFileSizeBytes = 5 * 1024 * 1024
  public static let maxFilesPerMessage = 3

  public static let allowedMIMETypes: Set<String> = [
    "image/jpeg", "image/png", "image/gif", "image/webp",
    "application/pdf",
    "text/plain", "text/csv", "text/markdown",
    "application/zip",
  ]

  public static var importableTypes: [UTType] {
    var types: [UTType] = [
      .jpeg, .png, .gif, .pdf, .plainText, .commaSeparatedText, .zip
    ]

    if let webP = UTType(mimeType: "image/webp") {
      types.append(webP)
    }

    if let markdown = UTType(filenameExtension: "md") {
      types.append(markdown)
    }

    return types
  }

  public static func validate(_ attachment: DashboardComposerAttachment) -> DashboardAttachmentValidationError? {
    if attachment.fileSizeBytes > maxFileSizeBytes {
      return .fileTooLarge(
        fileName: attachment.fileName,
        maxMB: maxFileSizeBytes / (1024 * 1024)
      )
    }

    if !allowedMIMETypes.contains(attachment.contentType) {
      return .unsupportedType(fileName: attachment.fileName)
    }

    return nil
  }
}
