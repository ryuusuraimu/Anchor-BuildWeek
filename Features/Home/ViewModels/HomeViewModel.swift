import Foundation
import Observation

@Observable
@MainActor
class HomeViewModel {
  private let readinessService: ReadinessService

  var readinessScore: Double { readinessService.totalReadiness }
  var shieldScore: Double { readinessService.shieldScore }
  var supporterScore: Double { readinessService.supporterScore }
  var practiceScore: Double { readinessService.practiceScore }

  var nextActionText: String { readinessService.nextAction }

  var showCelebration = false

  init(readinessService: ReadinessService? = nil) {
    self.readinessService = readinessService ?? .shared
  }

  func checkReadiness(settings: SettingsStore) {
    readinessService.recalculate(settings: settings)
    checkForCelebration()
  }

  func checkReadiness(contact: EmergencyContact?, settings: SettingsStore) {

    readinessService.recalculate(contact: contact, settings: settings)
    checkForCelebration()
  }

  func checkReadiness(contacts: [EmergencyContact], settings: SettingsStore) {
    readinessService.recalculate(contacts: contacts, settings: settings)
    checkForCelebration()
  }

  private func checkForCelebration() {
    // Trigger celebration if 100% and haven't lived it yet (today in this session)
    if readinessService.shouldCelebrate() {
      showCelebration = true
      readinessService.markCelebrated()
    }
  }

  func resetCelebration() {
    showCelebration = false
  }
}
