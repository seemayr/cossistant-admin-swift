import Foundation

public enum DashboardTimestampParser {
  private final class Cache: @unchecked Sendable {
    let lock = NSLock()
    let fractionalSecondsFormatter: ISO8601DateFormatter = {
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      return formatter
    }()
    let internetDateTimeFormatter: ISO8601DateFormatter = {
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime]
      return formatter
    }()
    let absoluteFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      formatter.timeStyle = .short
      return formatter
    }()
    let relativeFormatter: RelativeDateTimeFormatter = {
      let formatter = RelativeDateTimeFormatter()
      formatter.unitsStyle = .short
      return formatter
    }()
  }

  private static let cache = Cache()

  public static func date(from value: String?) -> Date? {
    guard let value, !value.isEmpty else { return nil }

    return withCache { cache in
      if value.contains("."),
         let date = cache.fractionalSecondsFormatter.date(from: value) {
        return date
      }

      if let date = cache.internetDateTimeFormatter.date(from: value) {
        return date
      }

      return cache.fractionalSecondsFormatter.date(from: value)
    }
  }

  public static func relativeString(from value: String?) -> String? {
    guard let date = date(from: value) else { return value }
    return relativeString(for: date, relativeTo: .now)
  }

  public static func absoluteString(from value: String?) -> String? {
    guard let date = date(from: value) else { return value }
    return absoluteString(for: date)
  }

  public static func relativeString(
    for date: Date,
    relativeTo referenceDate: Date = .now
  ) -> String {
    withCache { cache in
      cache.relativeFormatter.localizedString(for: date, relativeTo: referenceDate)
    }
  }

  public static func absoluteString(for date: Date) -> String {
    withCache { cache in
      cache.absoluteFormatter.string(from: date)
    }
  }

  public static func internetDateTimeString(from date: Date) -> String {
    withCache { cache in
      cache.internetDateTimeFormatter.string(from: date)
    }
  }

  private static func withCache<T>(_ operation: (Cache) -> T) -> T {
    cache.lock.lock()
    defer { cache.lock.unlock() }
    return operation(cache)
  }
}
