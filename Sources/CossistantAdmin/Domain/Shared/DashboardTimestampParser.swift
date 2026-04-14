import Foundation

public enum DashboardTimestampParser {
  public static func date(from value: String?) -> Date? {
    guard let value, !value.isEmpty else { return nil }

    for formatter in formatters() {
      if let date = formatter.date(from: value) {
        return date
      }
    }

    return nil
  }

  public static func relativeString(from value: String?) -> String? {
    guard let date = date(from: value) else { return value }
    return RelativeDateTimeFormatter.dashboardFormatter().localizedString(for: date, relativeTo: .now)
  }

  public static func absoluteString(from value: String?) -> String? {
    guard let date = date(from: value) else { return value }
    return dashboardDateTimeFormatter().string(from: date)
  }

  private static func formatters() -> [ISO8601DateFormatter] {
    [
      .dashboardWithFractionalSeconds(),
      .dashboardInternetDateTime(),
    ]
  }

  private static func dashboardDateTimeFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
  }
}
