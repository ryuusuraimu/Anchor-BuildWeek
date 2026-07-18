import AppIntents
import SwiftUI

@main
struct MyApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @StateObject private var router = AppRouter.shared
  @StateObject private var contactStore = EmergencyContactStore()
  @State private var settings = SettingsStore()

  init() {
    UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(
      BuildWeekDesign.Shelter.teal
    )
    UISegmentedControl.appearance().setTitleTextAttributes(
      [.foregroundColor: UIColor.white], for: .selected)
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(settings)
        .environmentObject(router)
        .tint(BuildWeekDesign.Shelter.teal)
        .onAppear {
          setupQuickActions()
          if #available(iOS 16.0, *) {
            ShieldShortcuts.updateAppShortcutParameters()
          }
        }
        .environmentObject(contactStore)
    }
  }

  private func setupQuickActions() {
    let shieldIcon = UIApplicationShortcutIcon(systemImageName: "shield.fill")
    let shieldItem = UIApplicationShortcutItem(
      type: "com.anchor.shield",
      localizedTitle: "Show Shield",
      localizedSubtitle: nil,
      icon: shieldIcon,
      userInfo: nil
    )

    let setupIcon = UIApplicationShortcutIcon(systemImageName: "wand.and.stars")
    let setupItem = UIApplicationShortcutItem(
      type: "com.anchor.setup",
      localizedTitle: "Support Setup",
      localizedSubtitle: nil,
      icon: setupIcon,
      userInfo: nil
    )

    UIApplication.shared.shortcutItems = [shieldItem, setupItem]
  }

  private func setupSpotlight() {
    let activity = NSUserActivity(activityType: "com.anchor.shield")
    activity.title = "Show Shield"
    activity.keywords = ["shield", "support", "help", "overwhelmed"]
    activity.isEligibleForSearch = true
    activity.isEligibleForPrediction = true
    activity.becomeCurrent()
  }
}
