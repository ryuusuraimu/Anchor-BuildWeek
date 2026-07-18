import SwiftUI

struct BuildWeekHomeView: View {
  @Binding var selectedTab: AppTab

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(SettingsStore.self) private var settings
  @EnvironmentObject private var contactStore: EmergencyContactStore

  @ScaledMetric(relativeTo: .largeTitle) private var heroSize: CGFloat = 44

  @State private var viewModel = HomeViewModel()
  @State private var shieldStorage = ShieldStorage.shared
  @State private var showShield = false
  @State private var showReset = false
  @State private var showAftercare = false
  @State private var showThemePicker = false
  @State private var showVoiceSettings = false
  @State private var fieldEngagement = 0.0

  @AppStorage("buildWeek.didCompleteOneMinuteAnchor") private var didCompletePreparation = false

  private var hasReviewedShield: Bool {
    didCompletePreparation && viewModel.shieldScore >= 1
  }

  private var callableContactCount: Int {
    contactStore.contacts.filter(\.hasCallablePhoneNumber).count
  }

  private var preparationCompletedCount: Int {
    let config = shieldStorage.config
    let preparedText = [
      config.situationText,
      config.doText,
      config.dontText,
      config.safetyText ?? "",
    ]
    .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    .count

    return min(5, preparedText + (callableContactCount > 0 ? 1 : 0))
  }

  private var preparationSubtitle: String {
    if preparationCompletedCount == 5 {
      return "5 of 5 ready"
    }
    return "\(preparationCompletedCount) of 5 prepared"
  }

  private var resolvedHeroSize: CGFloat {
    dynamicTypeSize.isAccessibilitySize ? min(heroSize, 62) : heroSize
  }

  var body: some View {
    NavigationStack {
      ZStack {
        LivingGeometryField(
          theme: settings.selectedTheme,
          mode: .resting,
          engagement: fieldEngagement
        )
        .ignoresSafeArea()

        GeometryReader { proxy in
          ScrollView {
            VStack(alignment: .leading, spacing: 0) {
              topBar

              hero
                .padding(.top, dynamicTypeSize.isAccessibilitySize ? 12 : 22)

              Spacer(minLength: dynamicTypeSize.isAccessibilitySize ? 54 : 178)

              openShieldButton

              utilityPanel
                .padding(.top, 12)
            }
            .frame(minHeight: max(0, proxy.size.height - 16), alignment: .top)
            .padding(.horizontal, BuildWeekDesign.Metric.screenPadding)
            .padding(.top, 4)
            .padding(.bottom, dynamicTypeSize.isAccessibilitySize ? 140 : 12)
          }
          .scrollIndicators(.hidden)
        }
      }
      .toolbar(.hidden, for: .navigationBar)
      .preferredColorScheme(.light)
      .fullScreenCover(isPresented: $showShield) {
        BuildWeekShieldView()
      }
      .fullScreenCover(isPresented: $showReset) {
        ResponsiveResetView()
      }
      .sheet(isPresented: $showAftercare) {
        BuildWeekAftercareView {
          DispatchQueue.main.async {
            showShield = true
          }
        }
        .presentationDragIndicator(.visible)
      }
      .sheet(isPresented: $showThemePicker) {
        ResponsiveThemePickerView()
          .presentationDragIndicator(.visible)
      }
      .sheet(isPresented: $showVoiceSettings) {
        BuildWeekVoiceSettingsView()
          .presentationDragIndicator(.visible)
      }
      .onAppear {
        refreshReadiness()
        applyDebugPresentation()
      }
      .onChange(of: contactStore.contacts) { _, _ in
        refreshReadiness()
      }
      .onChange(of: shieldStorage.config) { _, _ in
        refreshReadiness()
      }
    }
  }

  private var topBar: some View {
    HStack(spacing: 16) {
      Text("Anchor")
        .font(.system(.title3, design: .serif, weight: .medium))
        .tracking(-0.25)
        .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
        .dynamicTypeSize(.xSmall ... .accessibility1)
        .accessibilityAddTraits(.isHeader)

      Spacer(minLength: 16)

      Menu {
        Button {
          showAftercare = true
        } label: {
          Label("Check in", systemImage: "message")
        }

        Button {
          showThemePicker = true
        } label: {
          Label("Reset atmosphere", systemImage: settings.selectedTheme.symbolName)
        }

        Button {
          showVoiceSettings = true
        } label: {
          Label("Voice & reading", systemImage: "waveform")
        }
      } label: {
        Image(systemName: "ellipsis")
          .font(.system(size: 17, weight: .semibold))
          .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
          .frame(width: 44, height: 44)
          .contentShape(Rectangle())
      }
      .accessibilityLabel("More Home options")
      .accessibilityHint("Opens Check in, Reset atmosphere, and Voice and reading")
    }
    .frame(minHeight: 44)
  }

  private var hero: some View {
    Text("You have\na way to ask.")
      .font(.system(size: resolvedHeroSize, weight: .regular, design: .serif))
      .tracking(-1.15)
      .lineSpacing(-2)
      .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
      .fixedSize(horizontal: false, vertical: true)
      .accessibilityAddTraits(.isHeader)
  }

  private var openShieldButton: some View {
    Button {
      showShield = true
    } label: {
      HStack(spacing: 14) {
        Image(systemName: "shield")
          .font(.system(size: 21, weight: .medium))
          .accessibilityHidden(true)

        Text("Open Shield")
          .font(.headline)

        Spacer(minLength: 12)

        Image(systemName: "arrow.right")
          .font(.system(size: 17, weight: .semibold))
          .accessibilityHidden(true)
      }
      .foregroundStyle(Color(hex: "FAF7F0"))
      .dynamicTypeSize(.xSmall ... .accessibility2)
      .padding(.horizontal, 18)
      .padding(.vertical, 14)
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(minHeight: 62)
      .background(
        LinearGradient(
          colors: [
            BuildWeekDesign.HumanSignal.actionPressed,
            BuildWeekDesign.HumanSignal.action,
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )
      .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: 15, style: .continuous)
          .stroke(Color.white.opacity(0.22), lineWidth: 0.8)
      }
      .shadow(color: BuildWeekDesign.HumanSignal.ink.opacity(0.13), radius: 14, y: 8)
    }
    .buttonStyle(HumanSignalPrimaryButtonStyle(engagement: $fieldEngagement))
    .accessibilityLabel("Open Shield")
    .accessibilityValue(hasReviewedShield ? "Ready" : "Needs review")
    .accessibilityHint("Shows your prepared support instructions full screen")
  }

  private var utilityPanel: some View {
    VStack(spacing: 10) {
      HumanSignalUtilityRow(
        title: "Reset",
        subtitle: "Two minutes",
        icon: "circle.dotted"
      ) {
        showReset = true
      }

      HumanSignalUtilityRow(
        title: "Prepare",
        subtitle: preparationSubtitle,
        icon: "pencil"
      ) {
        selectedTab = .prepare
      }
    }
  }

  private func refreshReadiness() {
    viewModel.checkReadiness(contacts: contactStore.contacts, settings: settings)
  }

  private func applyDebugPresentation() {
    #if DEBUG
      let arguments = ProcessInfo.processInfo.arguments

      if let flagIndex = arguments.firstIndex(of: "-shelterTheme"),
        arguments.indices.contains(flagIndex + 1),
        let theme = AppTheme(rawValue: arguments[flagIndex + 1])
      {
        settings.selectedTheme = theme
      }

      if arguments.contains("-showAftercare") {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
          showAftercare = true
        }
      } else if arguments.contains("-showReset") {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
          showReset = true
        }
      } else if arguments.contains("-showThemePicker") {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
          showThemePicker = true
        }
      } else if arguments.contains("-showVoiceSettings") {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
          showVoiceSettings = true
        }
      }
    #endif
  }
}

private struct HumanSignalPrimaryButtonStyle: ButtonStyle {
  @Binding var engagement: Double
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
      .brightness(configuration.isPressed && !reduceMotion ? 0.035 : 0)
      .animation(
        reduceMotion ? nil : .spring(response: 0.26, dampingFraction: 0.88),
        value: configuration.isPressed
      )
      .onChange(of: configuration.isPressed, initial: true) { _, isPressed in
        engagement = isPressed ? 1 : 0
      }
  }
}

private struct HumanSignalUtilityRow: View {
  let title: String
  let subtitle: String
  let icon: String
  let action: () -> Void

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    Button(action: action) {
      Group {
        if dynamicTypeSize.isAccessibilitySize {
          VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 12) {
              rowIcon
              Text(title)
                .font(.headline)
              Spacer(minLength: 8)
              chevron
            }

            Text(subtitle)
              .font(.subheadline)
              .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
              .padding(.leading, 36)
          }
        } else {
          HStack(spacing: 12) {
            rowIcon

            VStack(alignment: .leading, spacing: 2) {
              Text(title)
                .font(.body.weight(.semibold))

              Text(subtitle)
                .font(.footnote)
                .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
            }

            Spacer(minLength: 8)
            chevron
          }
        }
      }
      .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
      .dynamicTypeSize(.xSmall ... .accessibility3)
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(minHeight: 62)
      .background(BuildWeekDesign.HumanSignal.surface)
      .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .stroke(BuildWeekDesign.HumanSignal.line.opacity(0.92), lineWidth: 0.8)
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityElement(children: .combine)
    .accessibilityHint("Opens \(title.lowercased())")
  }

  private var rowIcon: some View {
    Image(systemName: icon)
      .font(.system(size: 20, weight: .regular))
      .frame(width: 24)
      .accessibilityHidden(true)
  }

  private var chevron: some View {
    Image(systemName: "chevron.right")
      .font(.system(size: 14, weight: .semibold))
      .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
      .accessibilityHidden(true)
  }
}

#Preview("Human Signal Home") {
  BuildWeekHomeView(selectedTab: .constant(.home))
    .environment(SettingsStore())
    .environmentObject(EmergencyContactStore())
}
