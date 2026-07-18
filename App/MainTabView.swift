import SwiftUI

public enum AppTab: Hashable {
  case home, shield, prepare

  // Compatibility for legacy views that remain compiled but are no longer in
  // the Build Week navigation.
  static let studio = Self.prepare
  static let learn = Self.prepare
  static let journal = Self.home
}

struct MainTabView: View {
  @EnvironmentObject var router: AppRouter
  @State private var returnTab: AppTab = .home

  var body: some View {
    TabView(selection: $router.activeTab) {
      BuildWeekHomeView(selectedTab: $router.activeTab)
        .tabItem {
          Label("Home", systemImage: "house.fill")
            .dynamicTypeSize(.xSmall ... .accessibility2)
        }
        .tag(AppTab.home)

      Color.clear
        .accessibilityHidden(true)
        .tabItem {
          Label("Shield", systemImage: "shield.fill")
            .dynamicTypeSize(.xSmall ... .accessibility2)
        }
        .tag(AppTab.shield)

      OneMinuteAnchorView()
        .preferredColorScheme(.light)
        .tabItem {
          Label("Prepare", systemImage: "square.stack.3d.up.fill")
            .dynamicTypeSize(.xSmall ... .accessibility2)
        }
        .tag(AppTab.prepare)
    }
    .tint(BuildWeekDesign.HumanSignal.ink)
    .toolbarBackground(BuildWeekDesign.HumanSignal.backgroundWarm, for: .tabBar)
    .toolbarBackground(.visible, for: .tabBar)
    .toolbarColorScheme(.light, for: .tabBar)
    .preferredColorScheme(.light)
    .onAppear {
      #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-showPrepare") {
          router.activeTab = .prepare
        }
      #endif
    }
    .onChange(of: router.activeTab) { _, newTab in
      guard newTab == .shield else {
        returnTab = newTab
        return
      }

      let destination = returnTab
      DispatchQueue.main.async {
        router.activeTab = destination
        router.showShield = true
      }
    }
  }
}

#Preview {
  MainTabView()
    .environment(SettingsStore())
    .environmentObject(AppRouter.shared)
    .environmentObject(EmergencyContactStore())
}
