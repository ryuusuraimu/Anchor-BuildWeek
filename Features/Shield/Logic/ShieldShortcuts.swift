import AppIntents
import SwiftUI

@available(iOS 16.0, *)
struct DeployShieldIntent: AppIntent {
  static var title: LocalizedStringResource { "Deploy Shield" }
  static var description: IntentDescription {
    IntentDescription("Opens the prepared support card in Anchor.")
  }
  static var openAppWhenRun: Bool { true }

  @MainActor
  func perform() async throws -> some IntentResult {
    // Navigate to Shield
    AppRouter.shared.showShield = true
    return .result()
  }
}

@available(iOS 16.0, *)
struct CallEmergencyContactIntent: AppIntent {
  static var title: LocalizedStringResource { "Call Support Contact" }
  static var description: IntentDescription {
    IntentDescription("Calls the support contact saved in Anchor.")
  }
  static var openAppWhenRun: Bool { true }

  @MainActor
  func perform() async throws -> some IntentResult {
    // Retrieve contact
    if let contact = EmergencyContactStore.loadPrimaryContact(),
      let url = URL(string: "tel://\(contact.phone.filter { "0123456789+".contains($0) })")
    {
      // Open URL async
      _ = await UIApplication.shared.open(url)
    } else {
      // Fallback or open app
      // If standard open fails or no contact, app is already open due to openAppWhenRun
    }
    return .result()
  }
}

// Shortcuts Provider
@available(iOS 16.0, *)
struct ShieldShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: DeployShieldIntent(),
      phrases: [
        "Deploy Shield in \(.applicationName)",
        "Show Shield in \(.applicationName)",
        "Help me \(.applicationName)",
      ],
      shortTitle: "Deploy Shield",
      systemImageName: "shield.fill"
    )

    AppShortcut(
      intent: CallEmergencyContactIntent(),
      phrases: [
        "Call Support Contact in \(.applicationName)",
        "Call Support in \(.applicationName)",
      ],
      shortTitle: "Call Contact",
      systemImageName: "phone.fill"
    )
  }
}
