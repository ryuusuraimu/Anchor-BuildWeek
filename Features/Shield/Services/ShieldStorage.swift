import SwiftUI

@Observable
@MainActor
public class ShieldStorage {
  public static let shared = ShieldStorage()

  // We use AppStorage to persist the JSON string of the config
  // Access via a private property wrapper here, but expose a clean API
  private let storageKey = "shield_config_v3"
  private let practiceKey = "shield_practice_count"
  private let lastPracticeDateKey = "shield_last_practice_date"
  private let defaults = UserDefaults.standard

  // History Key
  private let historyKey = "shield_history_v1"

  public var config: ShieldConfig {
    didSet {
      save(config)
    }
  }

  public var practiceCount: Int {
    didSet {
      defaults.set(practiceCount, forKey: practiceKey)
    }
  }

  public var lastPracticeDate: Date? {
    didSet {
      defaults.set(lastPracticeDate, forKey: lastPracticeDateKey)
    }
  }

  private init() {
    if let data = defaults.data(forKey: storageKey),
      let decoded = try? JSONDecoder().decode(ShieldConfig.self, from: data)
    {
      self.config = decoded
    } else {
      self.config = ShieldConfig.defaults
    }

    self.practiceCount = defaults.integer(forKey: practiceKey)
    self.lastPracticeDate = defaults.object(forKey: lastPracticeDateKey) as? Date
  }

  private func save(_ config: ShieldConfig) {
    if let data = try? JSONEncoder().encode(config) {
      defaults.set(data, forKey: storageKey)
    }
  }

  // Helper to reset (mostly for testing/debug)
  public func resetToDefaults() {
    config = ShieldConfig.defaults
    practiceCount = 0
    lastPracticeDate = nil
    defaults.removeObject(forKey: storageKey)
    defaults.removeObject(forKey: practiceKey)
    defaults.removeObject(forKey: lastPracticeDateKey)
    defaults.removeObject(forKey: historyKey)
  }

  // MARK: - History

  public struct HistoryItem: Codable, Identifiable, Sendable {
    public let id: UUID
    public let date: Date
    public let config: ShieldConfig
    public let title: String?
    public let note: String?
    public let icon: String?
    public let themeColor: String?

    public init(
      id: UUID = UUID(),
      date: Date = Date(),
      config: ShieldConfig,
      title: String? = nil,
      note: String? = nil,
      icon: String? = nil,
      themeColor: String? = nil
    ) {
      self.id = id
      self.date = date
      self.config = config
      self.title = title
      self.note = note
      self.icon = icon
      self.themeColor = themeColor
    }
  }

  public func saveHistory(
    config: ShieldConfig,
    title: String? = nil,
    note: String? = nil,
    icon: String? = nil,
    themeColor: String? = nil
  ) {
    var history = loadHistory()
    let item = HistoryItem(
      config: config,
      title: title,
      note: note,
      icon: icon,
      themeColor: themeColor
    )
    history.insert(item, at: 0)  // Newest first

    // Limit to 50 items
    if history.count > 50 {
      history = Array(history.prefix(50))
    }

    if let data = try? JSONEncoder().encode(history) {
      defaults.set(data, forKey: historyKey)
    }
  }

  public func loadHistory() -> [HistoryItem] {
    guard let data = defaults.data(forKey: historyKey),
      let decoded = try? JSONDecoder().decode([HistoryItem].self, from: data)
    else {
      return []
    }
    return decoded
  }

  public func deleteHistoryItem(id: UUID) {
    var history = loadHistory()
    history.removeAll { $0.id == id }
    if let data = try? JSONEncoder().encode(history) {
      defaults.set(data, forKey: historyKey)
    }
  }
}
