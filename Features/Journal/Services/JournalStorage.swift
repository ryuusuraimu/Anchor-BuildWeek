import SwiftUI

// MARK: - Model
public struct JournalEntry: Codable, Identifiable, Sendable {
  public let id: UUID
  public let date: Date
  public let text: String
  public let mood: JournalMood

  public init(id: UUID = UUID(), date: Date = Date(), text: String, mood: JournalMood) {
    self.id = id
    self.date = date
    self.text = text
    self.mood = mood
  }
}

public enum JournalMood: String, Codable, CaseIterable, Identifiable, Sendable {
  case calm = "Calm"
  case happy = "Happy"
  case neutral = "Neutral"
  case anxious = "Anxious"
  case sad = "Sad"
  case tired = "Tired"

  public var id: String { rawValue }

  public var icon: String {
    switch self {
    case .calm: return "leaf.fill"
    case .happy: return "sun.max.fill"
    case .neutral: return "circle.fill"
    case .anxious: return "wind"
    case .sad: return "cloud.rain.fill"
    case .tired: return "bed.double.fill"
    }
  }

  public var colorHex: String {
    switch self {
    case .calm: return "#50A2A7"  // Calm Teal
    case .happy: return "#E0C068"  // Sunny Gold
    case .neutral: return "#9095A6"  // Soft Gray
    case .anxious: return "#E8927C"  // Warm Coral (used for alert)
    case .sad: return "#4E6E81"  // Muted Blue
    case .tired: return "#6D597A"  // Muted Purple
    }
  }
}

// MARK: - Storage
@Observable
@MainActor
public class JournalStorage {
  public static let shared = JournalStorage()
  private let key = "anchor_journal_entries_v1"
  private let defaults = UserDefaults.standard

  public private(set) var entries: [JournalEntry] = [] {
    didSet {
      save()
    }
  }

  private init() {
    load()
  }

  private func load() {
    if let data = defaults.data(forKey: key),
      let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data)
    {
      self.entries = decoded
    }
  }

  private func save() {
    if let data = try? JSONEncoder().encode(entries) {
      defaults.set(data, forKey: key)
    }
  }

  public func addEntry(text: String, mood: JournalMood) {
    let entry = JournalEntry(text: text, mood: mood)
    entries.insert(entry, at: 0)  // Newest first
  }

  public func deleteEntry(id: UUID) {
    entries.removeAll { $0.id == id }
  }

  public func clearAll() {
    entries = []
    defaults.removeObject(forKey: key)
  }
}
