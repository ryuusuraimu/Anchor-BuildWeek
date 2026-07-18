import Foundation
import Observation

@Observable
@MainActor
class ReadinessService {
  public static let shared = ReadinessService()

  // Dependencies
  private let shieldStorage: ShieldStorage
  // Recompute on demand; callers should invoke `recalculate(...)` when inputs change.

  // Current Scores (0.0 - 1.0)
  var shieldScore: Double = 0.0
  var supporterScore: Double = 0.0
  var practiceScore: Double = 0.0

  // Celebration Tracking
  private var lastCelebrationDate: Date? = nil

  var totalReadiness: Double {
    (shieldScore + supporterScore + practiceScore) / 3.0
  }

  private init(shieldStorage: ShieldStorage? = nil) {
    self.shieldStorage = shieldStorage ?? .shared
    // Initialize defaults, then recalculate
    self.shieldScore = 0.0
    self.supporterScore = 0.0
    self.practiceScore = 0.0

    // Initial calculation runs after init to keep startup lightweight.
    Task { @MainActor in
      self.recalculate()
    }
  }

  func recalculate(settings: SettingsStore? = nil) {
    recalculate(contacts: EmergencyContactStore.loadStandard(), settings: settings)
  }

  func recalculate(contact: EmergencyContact?, settings: SettingsStore? = nil) {
    recalculate(contacts: contact.map { [$0] } ?? [], settings: settings)
  }

  func recalculate(contacts: [EmergencyContact], settings: SettingsStore? = nil) {
    // 1. Shield Setup
    // Done if all 3 blocks have non-empty text
    let config = shieldStorage.config
    let hasSituation = !config.situationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    let hasDo = !config.doText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    let hasDont = !config.dontText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

    shieldScore = (hasSituation && hasDo && hasDont) ? 1.0 : 0.0

    // 2. Support Contact Ready
    // Done if at least one support relay contact is set
    if contacts.contains(where: \.hasCallablePhoneNumber) {
      supporterScore = 1.0
    } else {
      supporterScore = 0.0
    }

    // 3. Practice
    // Done if practiceCount >= 1
    practiceScore = shieldStorage.practiceCount >= 1 ? 1.0 : 0.0
  }

  var nextAction: String {
    if shieldScore < 1.0 { return "Create Shield" }
    if supporterScore < 1.0 { return "Add Support Contact" }
    if practiceScore < 1.0 { return "Practice Shield" }
    return ""
  }

  // MARK: - Celebration Logic

  func shouldCelebrate() -> Bool {
    guard totalReadiness >= 1.0 else { return false }

    guard let lastDate = lastCelebrationDate else { return true }

    // Check if last celebration was NOT today
    return !Calendar.current.isDateInToday(lastDate)
  }

  func markCelebrated() {
    lastCelebrationDate = Date()
  }
}
