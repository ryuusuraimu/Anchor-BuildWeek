import SwiftUI

struct ContentView: View {
  @EnvironmentObject var router: AppRouter

  var body: some View {
    PortraitOnlyContainer {
      MainTabView()
    }
    // Shield mode
    .fullScreenCover(isPresented: $router.showShield) {
      BuildWeekShieldView()
    }
    .onAppear(perform: applyDebugLaunchRoute)
    .onOpenURL { url in
      router.handle(url: url)
    }
    .onContinueUserActivity("com.anchor.shield") { activity in
      router.handle(userActivity: activity)
    }
    .onContinueUserActivity("com.anchor.setup") { activity in
      router.handle(userActivity: activity)
    }
  }

  private func applyDebugLaunchRoute() {
    #if DEBUG
      let arguments = ProcessInfo.processInfo.arguments
      if arguments.contains("-showHome") {
        router.showShield = false
        router.activeTab = .home
      } else if arguments.contains("-showShield") {
        DispatchQueue.main.async {
          router.showShield = true
        }
      } else if arguments.contains("-showPrepare")
        || arguments.contains("-showContactEditor")
      {
        router.activeTab = .prepare
      }
    #endif
  }
}
