import Combine
import SwiftUI

@MainActor
class AppRouter: ObservableObject {
  // Navigation State
  @Published var showShield = false
  @Published var activeTab: AppTab = .home
  // Retained so legacy compiled views remain source-compatible. The Build Week
  // app routes setup requests to the focused Prepare flow instead.
  @Published var showSetupWizard = false

  // Pending Actions (for cold launch)
  private var pendingAction: (() -> Void)?

  // Singleton
  static let shared = AppRouter()
  private init() {}

  // MARK: - Route Handling

  func handle(url: URL) {
    guard url.scheme == "anchor" else { return }

    switch url.host {
    case "shield":
      navigateToShield()
    case "setup":
      navigateToSetup()
    case "learn":
      navigateToLearn()
    default:
      break
    }
  }

  func handle(shortcutItem: UIApplicationShortcutItem) {
    switch shortcutItem.type {
    case "com.anchor.shield":
      navigateToShield()
    case "com.anchor.setup":
      navigateToSetup()
    default:
      break
    }
  }

  func handle(userActivity: NSUserActivity) {
    // Searchable Item or Siri Suggestion
    switch userActivity.activityType {
    case "com.anchor.shield":
      navigateToShield()
    case "com.anchor.setup":
      navigateToSetup()
    default:
      break
    }
  }

  // MARK: - Navigation Logic

  private func navigateToShield() {
    // Present Shield as a full-screen flow.
    DispatchQueue.main.async {
      self.showShield = true
    }
  }

  private func navigateToSetup() {
    DispatchQueue.main.async {
      self.activeTab = .prepare
    }
  }

  private func navigateToLearn() {
    DispatchQueue.main.async {
      self.activeTab = .prepare
    }
  }
}
