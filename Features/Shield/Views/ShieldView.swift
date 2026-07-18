import SwiftUI
import UIKit

struct ShieldView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(SettingsStore.self) private var settings
  @EnvironmentObject var contactStore: EmergencyContactStore

  // One-time reviewer guidance: show a lightweight toast after the first deploy
  // so the lock screen card (Now Playing) is not missed during review.
  @AppStorage("didShowDeployLockScreenToast") private var didShowDeployLockScreenToast = false
  @State private var showDeployLockScreenToast = false

  // Engine
  @StateObject private var engine: ShieldEngine

  // UI State
  @State private var showQR = false
  @State private var isListView = false
  @State private var activeRelayIndex = 0

  // System Services
  @State private var brightness = BrightnessService()
  @State private var idleTimer = IdleTimerService()

  // Haptics
  private let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)

  // Internal Config for Overrides (Preview)
  private let previewConfig: ShieldConfig?

  init(config: ShieldConfig? = nil) {
    self.previewConfig = config
    // Initialize engine with config from storage or override
    let effectiveConfig = config ?? ShieldStorage.shared.config
    _engine = StateObject(wrappedValue: ShieldEngine(config: effectiveConfig))
  }

  var body: some View {
    ZStack {
      // 1. Deep Dark Background
      Color.black.ignoresSafeArea()

      RadialGradient(
        gradient: Gradient(colors: [
          currentCardColor.opacity(0.3),
          Color.black,
        ]),
        center: .center,
        startRadius: 5,
        endRadius: 500
      )
      .ignoresSafeArea()
      .animation(.easeInOut(duration: 1.0), value: engine.currentCard)

      // 2. Content Layout
      VStack(spacing: 24) {

        // Header Controls
        HStack {
          HoldToCloseButton {
            engine.stop()
            dismiss()
          }

          Spacer()

          // Audio Toggle (Stop Speaking)
          Button {
            engine.toggleVoice(!engine.isVoiceEnabled)
            impactGenerator.impactOccurred()
            if engine.isVoiceEnabled {
              speakCurrentCard()
            }
          } label: {
            Image(systemName: engine.isVoiceEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
              .foregroundColor(.white.opacity(0.8))
              .padding(8)
          }

          // List View Toggle
          Button {
            withAnimation(.spring()) {
              isListView.toggle()
            }
            impactGenerator.impactOccurred()
          } label: {
            Image(
              systemName: isListView
                ? "rectangle.portrait.on.rectangle.portrait.fill" : "list.bullet"
            )
            .foregroundColor(.white.opacity(isListView ? 1.0 : 0.6))
            .padding(8)
          }

          Spacer()

          HStack(spacing: 16) {
            // QR
            Button {
              showQR = true
            } label: {
              Image(systemName: "qrcode")
                .font(.system(size: 24))
                .foregroundColor(.white)
            }

            // Call
            if activeRelayContact != nil {
              Button {
                callActiveRelayContact()
              } label: {
                Image(systemName: "phone.fill")
                  .font(.system(size: 24))
                  .foregroundColor(DesignSystem.Colors.calmTeal)
              }
              .accessibilityLabel("Call current support contact")
            }
          }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)

        if isListView {
          // List View
          ScrollView {
            VStack(spacing: 24) {
              ForEach(ShieldEngine.CardState.allCases, id: \.self) { state in
                let content = getContent(for: state)

                VStack(alignment: .leading, spacing: 12) {
                  HStack {
                    Image(systemName: content.icon)
                      .font(.title2)
                      .foregroundColor(content.color)
                    Text(content.title)
                      .font(.headline)
                      .foregroundColor(content.color.opacity(0.8))
                      .textCase(.uppercase)
                    Spacer()
                  }

                  Text(content.text)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding(20)
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
                .overlay(
                  RoundedRectangle(cornerRadius: 16)
                    .stroke(content.color.opacity(0.3), lineWidth: 1)
                )
              }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .padding(.top, 20)  // Add some top padding since we removed the Spacer
          }
        } else {
          Spacer()

          // Main Card (Single Large Display)
          VStack(spacing: 16) {
            // Icon
            Image(systemName: currentCardIcon)
              .font(.system(size: 60))
              .foregroundColor(currentCardColor)
              .padding(.bottom, 16)

            // Title
            Text(currentCardTitle)
              .font(.system(size: 20, weight: .bold, design: .monospaced))
              .foregroundColor(currentCardColor.opacity(0.8))
              .kerning(2)
              .textCase(.uppercase)

            // Text (Huge)
            Text(currentCardText)
              .font(.system(size: 40, weight: .bold, design: .rounded))  // Very large
              .foregroundColor(.white)
              .multilineTextAlignment(.center)
              .minimumScaleFactor(0.4)
              .padding(.horizontal)
              .frame(maxHeight: .infinity)

          }
          .padding()
          .contentShape(Rectangle())  // Tappable area
          .onTapGesture {
            engine.nextCard()
            impactGenerator.impactOccurred()
          }
          .transition(.opacity)
          .id(engine.currentCard)  // Force transition

          Spacer()

          // Pagination Dots
          HStack(spacing: 12) {
            ForEach(ShieldEngine.CardState.allCases, id: \.self) { state in
              Circle()
                .fill(engine.currentCard == state ? currentCardColor : Color.white.opacity(0.2))
                .frame(width: 8, height: 8)
            }
          }
          .padding(.bottom, contactStore.contacts.isEmpty ? 40 : 8)

          supportRelayPanel
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
        }
      }
    }
    .buttonStyle(NoSelectionButtonStyle())
    .statusBar(hidden: true)
    .onAppear {
      updateSystemServices()
      engine.start(
        speechEnabled: settings.shieldSpeechEnabled,
        hapticsEnabled: settings.shieldHapticsEnabled,
        autoCycleEnabled: settings.shieldAutoCycleEnabled,
        cycleInterval: settings.shieldCycleInterval
      )

      showOneTimeDeployToastIfNeeded()
      activeRelayIndex = min(activeRelayIndex, max(0, contactStore.contacts.count - 1))
    }
    .onChange(of: contactStore.contacts) { _, contacts in
      activeRelayIndex = min(activeRelayIndex, max(0, contacts.count - 1))
    }
    .onChange(of: settings.increaseBrightnessOnShieldCard) { _, _ in updateSystemServices() }
    .onChange(of: settings.preventScreenSleepOnShieldCard) { _, _ in updateSystemServices() }
    .onDisappear {
      engine.stop()
      brightness.restore()
      idleTimer.restore()
    }
    .fullScreenCover(isPresented: $showQR) {
      ShieldQRCodeView(config: previewConfig ?? ShieldStorage.shared.config)
    }
    .onChange(of: engine.currentCard) { _, _ in
      if engine.isVoiceEnabled {
        speakCurrentCard()
      }
    }

    .overlay(alignment: .top) {
      if showDeployLockScreenToast {
        ShieldToastBanner(
          text: deployToastText,
          onDismiss: {
            withAnimation(.easeOut(duration: 0.2)) {
              showDeployLockScreenToast = false
            }
          }
        )
        // Place below the header row so it never overlaps the close/toggles.
        .padding(.top, 92)
        .padding(.horizontal, 18)
        .transition(.move(edge: .top).combined(with: .opacity))
      }
    }

  }


  private var deployToastText: String {
    if RuntimeEnvironment.isSimulator && RuntimeEnvironment.isIPhone {
      return "Tip: iPhone Simulator may not show the Lock Screen Card. Verify on a real iPhone."
    }
    return "Tip: Lock your device to confirm the Lock Screen Card (Now Playing)."
  }

  @ViewBuilder
  private var supportRelayPanel: some View {
    if let contact = activeRelayContact {
      VStack(spacing: 12) {
        HStack(alignment: .center, spacing: 12) {
          VStack(alignment: .leading, spacing: 4) {
            Text("Support Relay")
              .font(.system(size: 13, weight: .bold, design: .rounded))
              .foregroundColor(.white.opacity(0.58))
              .textCase(.uppercase)
              .tracking(1.1)

            Text(contact.name)
              .font(.system(size: 24, weight: .bold, design: .rounded))
              .foregroundColor(.white)
              .lineLimit(1)
              .minimumScaleFactor(0.72)

            Text("Contact \(activeRelayIndex + 1) of \(contactStore.contacts.count)")
              .font(.system(size: 14, weight: .semibold, design: .rounded))
              .foregroundColor(currentCardColor.opacity(0.9))
          }

          Spacer(minLength: 0)

          if contactStore.contacts.count > 1 {
            Button(action: advanceRelayContact) {
              VStack(spacing: 4) {
                Image(systemName: "arrow.right.circle.fill")
                  .font(.system(size: 30, weight: .bold))
                Text("Next")
                  .font(.system(size: 14, weight: .bold, design: .rounded))
              }
              .foregroundColor(.white.opacity(0.88))
              .frame(width: 82, height: 76)
              .background(Color.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
              .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                  .stroke(Color.white.opacity(0.18), lineWidth: 1)
              )
            }
            .accessibilityLabel("Next support contact")
            .accessibilityHint("Moves to the next person in your support relay.")
            .accessibilitySortPriority(2)
          }
        }

        if contactStore.contacts.count > 1 {
          Text("If unavailable, tap Next.")
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundColor(.white.opacity(0.62))
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        Button(action: callActiveRelayContact) {
          HStack(spacing: 12) {
            Image(systemName: "phone.fill")
              .font(.system(size: 24, weight: .bold))
            Text("Call \(contact.name)")
              .font(.system(size: 22, weight: .bold, design: .rounded))
              .lineLimit(1)
              .minimumScaleFactor(0.72)
          }
          .foregroundColor(.black)
          .frame(maxWidth: .infinity)
          .frame(minHeight: 68)
          .background(currentCardColor, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .accessibilityLabel("Call \(contact.name)")
        .accessibilityHint("Opens the phone app. iOS will ask before calling.")
        .accessibilitySortPriority(3)
      }
      .padding(16)
      .background(Color.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
      .overlay(
        RoundedRectangle(cornerRadius: 26, style: .continuous)
          .stroke(currentCardColor.opacity(0.28), lineWidth: 1)
      )
      .accessibilityElement(children: .contain)
    }
  }

  private func showOneTimeDeployToastIfNeeded() {
    guard !didShowDeployLockScreenToast else { return }
    didShowDeployLockScreenToast = true

    // Delay slightly so the view has laid out, then show briefly.
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
      withAnimation(.spring(response: 0.35, dampingFraction: 0.92)) {
        showDeployLockScreenToast = true
      }
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
      withAnimation(.easeOut(duration: 0.25)) {
        showDeployLockScreenToast = false
      }
    }
  }

private struct ShieldToastBanner: View {
  let text: String
  let onDismiss: () -> Void

  var body: some View {
    HStack(spacing: 10) {
      Image(systemName: "lock.fill")
        .font(.system(size: 14, weight: .semibold))
        .foregroundColor(.white.opacity(0.9))

      Text(text)
        .font(.system(size: 14, weight: .semibold, design: .rounded))
        .foregroundColor(.white.opacity(0.95))
        .lineLimit(2)
        .multilineTextAlignment(.leading)

      Spacer(minLength: 0)

      Button(action: onDismiss) {
        Image(systemName: "xmark")
          .font(.system(size: 12, weight: .bold))
          .foregroundColor(.white.opacity(0.85))
          .padding(6)
          .background(Color.white.opacity(0.12), in: Circle())
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Dismiss tip")
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 12)
    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
    .overlay(
      RoundedRectangle(cornerRadius: 18)
        .stroke(Color.white.opacity(0.18), lineWidth: 1)
    )
  }
}

  private func getContent(for state: ShieldEngine.CardState) -> (
    title: String, text: String, color: Color, icon: String
  ) {
    let config = previewConfig ?? ShieldStorage.shared.config

    let title: String
    let text: String
    let color: Color
    let icon: String

    switch state {
    case .situation:
      title = "Situation"
      text = config.situationText
      color = DesignSystem.Colors.warmCoral
      icon = "exclamationmark.triangle.fill"
    case .doAction:
      title = "Please Do"
      text = config.doText
      color = DesignSystem.Colors.calmTeal
      icon = "checkmark.circle.fill"
    case .dontAction:
      title = "Please Don't"
      text = config.dontText
      color = Color(hex: "E57373")
      icon = "hand.raised.fill"
    case .safety:
      title = "Safety"
      text = config.safetyText ?? ""
      color = Color(hex: "FF5252")
      icon = "cross.case.fill"
    }

    return (title, text, color, icon)
  }

  // Computed Helpers for UI (Legacy wrappers)
  private var currentCardTitle: String { getContent(for: engine.currentCard).title }
  private var currentCardText: String { getContent(for: engine.currentCard).text }
  private var currentCardColor: Color { getContent(for: engine.currentCard).color }
  private var currentCardIcon: String { getContent(for: engine.currentCard).icon }
  private var activeRelayContact: EmergencyContact? {
    guard contactStore.contacts.indices.contains(activeRelayIndex) else {
      return contactStore.contacts.first
    }
    return contactStore.contacts[activeRelayIndex]
  }

  private func callActiveRelayContact() {
    guard let contact = activeRelayContact else { return }
    let sanitized = contact.phone.filter { "0123456789+".contains($0) }
    guard let url = URL(string: "tel://\(sanitized)") else { return }
    UIApplication.shared.open(url)
  }

  private func advanceRelayContact() {
    guard !contactStore.contacts.isEmpty else { return }
    withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
      activeRelayIndex = (activeRelayIndex + 1) % contactStore.contacts.count
    }
    impactGenerator.impactOccurred()
  }

  private func updateSystemServices() {
    brightness.applyEmergencyBrightness(enabled: settings.increaseBrightnessOnShieldCard)
    idleTimer.preventSleep(enabled: settings.preventScreenSleepOnShieldCard)
  }

  private func speakCurrentCard() {
    let text = currentCardText
    // Remove newlines for smoother speech
    let cleanText = text.replacingOccurrences(of: "\n", with: " ")
    engine.speak(text: cleanText, language: "en-US")
  }
}

#Preview {
  ShieldView()
    .environment(SettingsStore())
}
