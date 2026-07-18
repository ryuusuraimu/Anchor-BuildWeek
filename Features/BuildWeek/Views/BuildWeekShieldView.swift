import NaturalLanguage
import SwiftUI
import UIKit

struct BuildWeekShieldView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(SettingsStore.self) private var settings
  @EnvironmentObject private var contactStore: EmergencyContactStore

  @StateObject private var engine: ShieldEngine
  @State private var showQR = false
  @State private var activeRelayIndex = 0
  @State private var practiceCallWasTested = false
  @State private var brightness = BrightnessService()
  @State private var idleTimer = IdleTimerService()
  @ScaledMetric(relativeTo: .largeTitle) private var situationFontSize: CGFloat = 34

  private let config: ShieldConfig
  private let isPractice: Bool
  private let impactGenerator = UIImpactFeedbackGenerator(style: .soft)

  init(config: ShieldConfig? = nil, isPractice: Bool = false) {
    let resolvedConfig = Self.debugConfigOverride(
      config ?? ShieldStorage.shared.config
    )
    self.config = resolvedConfig
    self.isPractice = isPractice || Self.debugForcesPractice
    _engine = StateObject(
      wrappedValue: ShieldEngine(config: resolvedConfig)
    )
  }

  var body: some View {
    ZStack {
      BuildWeekDesign.Signal.background
        .ignoresSafeArea()

      VStack(spacing: 0) {
        shieldHeader

        ScrollView {
          VStack(alignment: .leading, spacing: 0) {
            if isPractice {
              Text("PRACTICE — NO CALLS WILL BE PLACED")
                .font(.caption.weight(.bold))
                .tracking(1.1)
                .foregroundStyle(BuildWeekDesign.Signal.support)
                .dynamicTypeSize(.xSmall ... .accessibility2)
                .padding(.bottom, 22)
            }

            Text(config.situationText)
              .font(
                .system(
                  size: min(situationFontSize, dynamicTypeSize.isAccessibilitySize ? 44 : 38),
                  weight: .bold,
                  design: .default
                )
              )
              .tracking(-0.7)
              .foregroundStyle(BuildWeekDesign.Signal.ivory)
              .fixedSize(horizontal: false, vertical: true)
              .padding(.leading, 22)
              .overlay(alignment: .leading) {
                Capsule()
                  .fill(BuildWeekDesign.Signal.action)
                  .frame(width: 4)
                  .padding(.vertical, 2)
                  .accessibilityHidden(true)
              }
              .accessibilityAddTraits(.isHeader)

            if let safetyText = config.safetyText, !safetyText.isEmpty {
              SignalSafetyBand(text: safetyText)
                .padding(.top, 24)
            }

            SignalGuidanceSheet(
              doText: config.doText,
              dontText: config.dontText
            )
            .padding(.top, 30)
          }
          .padding(.horizontal, BuildWeekDesign.Metric.screenPadding)
          .padding(.top, 22)
          .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
      }
    }
    .safeAreaInset(edge: .bottom, spacing: 0) {
      if showsRelayDock {
        supportRelayPanel
      }
    }
    .statusBar(hidden: true)
    .buttonStyle(.plain)
    .onAppear {
      updateSystemServices()
      activeRelayIndex = min(
        Self.debugInitialRelayIndex,
        max(0, relayContacts.count - 1)
      )
      engine.start(
        speechEnabled: settings.shieldSpeechEnabled,
        hapticsEnabled: settings.shieldHapticsEnabled,
        autoCycleEnabled: false,
        cycleInterval: settings.shieldCycleInterval
      )
      #if DEBUG
        if Self.debugShowsQRInitially {
          DispatchQueue.main.async {
            showQR = true
          }
        }
      #endif
    }
    .onChange(of: contactStore.contacts) { _, contacts in
      guard debugContactsOverride == nil else { return }
      activeRelayIndex = min(activeRelayIndex, max(0, contacts.count - 1))
    }
    .onChange(of: settings.increaseBrightnessOnShieldCard) { _, _ in
      updateSystemServices()
    }
    .onChange(of: settings.preventScreenSleepOnShieldCard) { _, _ in
      updateSystemServices()
    }
    .onDisappear {
      engine.stop()
      brightness.restore()
      idleTimer.restore()
    }
    .fullScreenCover(isPresented: $showQR) {
      ShieldQRCodeView(config: config, contactsOverride: debugContactsOverride)
    }
  }

  private var shieldHeader: some View {
    Group {
      if dynamicTypeSize.isAccessibilitySize {
        VStack(alignment: .leading, spacing: 8) {
          closeButton
          HStack(spacing: 8) {
            readAloudButton(expand: true)
            qrButton(expand: false)
          }
        }
      } else {
        HStack(spacing: 8) {
          closeButton
          Spacer(minLength: 4)
          readAloudButton(expand: false)
          qrButton(expand: false)
        }
      }
    }
    .padding(.horizontal, BuildWeekDesign.Metric.screenPadding)
    .padding(.top, 12)
    .padding(.bottom, 12)
    .background(BuildWeekDesign.Signal.background)
  }

  private var closeButton: some View {
    HoldToCloseButton(action: finish, hapticsEnabled: settings.shieldHapticsEnabled)
      .accessibilityLabel("Close Shield")
      .accessibilityHint("With VoiceOver, double-tap twice. Otherwise, press and hold.")
  }

  private func readAloudButton(expand: Bool) -> some View {
    headerButton(
      title: engine.isVoiceEnabled ? "Stop reading" : "Read aloud",
      icon: engine.isVoiceEnabled ? "stop.fill" : "speaker.wave.2.fill",
      accessibilityLabel: engine.isVoiceEnabled ? "Stop reading aloud" : "Read instructions aloud",
      expand: expand
    ) {
      engine.toggleVoice(!engine.isVoiceEnabled)
      if settings.shieldHapticsEnabled {
        impactGenerator.impactOccurred()
      }
      if engine.isVoiceEnabled {
        let preparedAudio = ShieldVoiceLibrary.shared.cachedSpeechURL(
          text: combinedSpeechText,
          voice: settings.selectedOpenAIVoice
        )
        engine.speak(
          text: combinedSpeechText,
          language: speechLanguage,
          preparedAudioURL: preparedAudio
        )
      }
    }
  }

  private func qrButton(expand: Bool) -> some View {
    headerButton(
      title: "QR",
      icon: "qrcode",
      accessibilityLabel: "Show QR support card",
      expand: expand
    ) {
      showQR = true
      if settings.shieldHapticsEnabled {
        impactGenerator.impactOccurred()
      }
    }
    .accessibilityHint("Opens a shareable QR version of these instructions.")
  }

  private func headerButton(
    title: String,
    icon: String,
    accessibilityLabel: String,
    expand: Bool,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      Label(title, systemImage: icon)
        .font(.subheadline.bold())
        .fontDesign(.default)
        .foregroundStyle(BuildWeekDesign.Signal.ivory)
        .padding(.horizontal, 12)
        .frame(maxWidth: expand ? .infinity : nil)
        .frame(minHeight: BuildWeekDesign.Metric.shieldUtility)
        .fixedSize(horizontal: !expand, vertical: true)
        .contentShape(Rectangle())
    }
    .accessibilityLabel(accessibilityLabel)
    .dynamicTypeSize(.xSmall ... .accessibility2)
  }

  @ViewBuilder
  private var supportRelayPanel: some View {
    if let contact = activeRelayContact {
      VStack(spacing: 12) {
        ViewThatFits(in: .horizontal) {
          HStack(alignment: .center, spacing: 12) {
            supportContactIdentity(contact, preserveIdealWidth: true)

            Spacer(minLength: 8)

            if relayContacts.count > 1 {
              nextRelayButton
            }
          }

          VStack(alignment: .leading, spacing: 12) {
            supportContactIdentity(contact, preserveIdealWidth: false)

            if relayContacts.count > 1 {
              nextRelayButton
            }
          }
        }

        if let callURL = callURL(for: contact) {
          if isPractice {
            practiceCallButton(for: contact)
          } else {
            callButton(for: contact, url: callURL)
          }
        } else {
          unavailablePhoneNotice
        }
      }
      .padding(.horizontal, BuildWeekDesign.Metric.screenPadding)
      .padding(.top, 14)
      .padding(.bottom, 10)
      .background(BuildWeekDesign.Signal.background)
      .overlay(alignment: .top) {
        Rectangle()
          .fill(BuildWeekDesign.Signal.line)
          .frame(height: 1)
      }
      .accessibilityElement(children: .contain)
    }
  }

  private var showsRelayDock: Bool {
    guard let contact = activeRelayContact else { return false }
    return callURL(for: contact) != nil || relayContacts.count > 1
  }

  private var relayContacts: [EmergencyContact] {
    debugContactsOverride ?? contactStore.contacts
  }

  private var activeRelayContact: EmergencyContact? {
    guard relayContacts.indices.contains(activeRelayIndex) else {
      return relayContacts.first
    }
    return relayContacts[activeRelayIndex]
  }

  private var combinedSpeechText: String {
    ShieldSpeechText.make(from: config)
  }

  private var speechLanguage: String {
    let source = [
      config.situationText,
      config.doText,
      config.dontText,
      config.safetyText,
    ]
    .compactMap { $0 }
    .joined(separator: " ")

    let recognizer = NLLanguageRecognizer()
    recognizer.processString(source)
    return recognizer.dominantLanguage?.rawValue
      ?? Locale.preferredLanguages.first
      ?? "en"
  }

  private func supportContactIdentity(
    _ contact: EmergencyContact,
    preserveIdealWidth: Bool
  ) -> some View {
    VStack(alignment: .leading, spacing: 3) {
      Text("SUPPORT CONTACT")
        .font(.caption2.weight(.bold))
        .fontDesign(.default)
        .tracking(1.1)
        .foregroundStyle(BuildWeekDesign.Signal.support)

      Text(contact.name)
        .font(.title3.bold())
        .fontDesign(.default)
        .foregroundStyle(BuildWeekDesign.Signal.ivory)
        .fixedSize(horizontal: preserveIdealWidth, vertical: true)

      if relayContacts.count > 1 {
        Text("Contact \(activeRelayIndex + 1) of \(relayContacts.count)")
          .font(.footnote.weight(.semibold))
          .fontDesign(.default)
          .foregroundStyle(BuildWeekDesign.Signal.ivory.opacity(0.6))
      }
    }
    .accessibilityElement(children: .combine)
    .dynamicTypeSize(.xSmall ... .accessibility3)
  }

  private var nextRelayButton: some View {
    Button(action: advanceRelayContact) {
      Label("Next contact", systemImage: "arrow.right")
        .font(.body.bold())
        .fontDesign(.default)
        .foregroundStyle(BuildWeekDesign.Signal.ivory)
        .padding(.horizontal, 16)
        .frame(minHeight: 56)
        .background(
          BuildWeekDesign.Signal.surface,
          in: RoundedRectangle(cornerRadius: 17, style: .continuous)
        )
        .overlay(
          RoundedRectangle(cornerRadius: 17, style: .continuous)
            .stroke(BuildWeekDesign.Signal.line, lineWidth: 1)
        )
    }
    .accessibilityLabel("Next support contact")
    .accessibilityHint("Moves to the next person in your support relay.")
    .accessibilitySortPriority(2)
    .dynamicTypeSize(.xSmall ... .accessibility3)
  }

  private func callButton(for contact: EmergencyContact, url: URL) -> some View {
    Button {
      UIApplication.shared.open(url)
    } label: {
      ViewThatFits(in: .horizontal) {
        HStack(spacing: 12) {
          Image(systemName: "phone.fill")
          Text("Call \(contact.name)")
        }

        VStack(spacing: 8) {
          Image(systemName: "phone.fill")
          Text("Call \(contact.name)")
            .multilineTextAlignment(.center)
        }
      }
      .font(.title3.bold())
      .fontDesign(.default)
      .dynamicTypeSize(.xSmall ... .accessibility3)
      .foregroundStyle(BuildWeekDesign.Signal.background)
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .frame(maxWidth: .infinity)
      .frame(minHeight: BuildWeekDesign.Metric.crisisAction)
      .background(
        BuildWeekDesign.Signal.action,
        in: RoundedRectangle(cornerRadius: 22, style: .continuous)
      )
    }
    .accessibilityLabel("Call \(contact.name)")
    .accessibilityHint("Opens the phone app. iOS will ask before calling.")
    .accessibilitySortPriority(3)
  }

  private func practiceCallButton(for contact: EmergencyContact) -> some View {
    Button {
      practiceCallWasTested = true
      if settings.shieldHapticsEnabled {
        impactGenerator.impactOccurred()
      }
      UIAccessibility.post(
        notification: .announcement,
        argument: "Practice only. No phone call was placed."
      )
    } label: {
      ViewThatFits(in: .horizontal) {
        HStack(spacing: 12) {
          Image(systemName: practiceCallWasTested ? "checkmark" : "phone.fill")
          Text(
            practiceCallWasTested
              ? "Practice call checked"
              : "Practice: Call \(contact.name)"
          )
        }

        VStack(spacing: 8) {
          Image(systemName: practiceCallWasTested ? "checkmark" : "phone.fill")
          Text(
            practiceCallWasTested
              ? "Practice call checked"
              : "Practice: Call \(contact.name)"
          )
          .multilineTextAlignment(.center)
        }
      }
      .font(.title3.bold())
      .fontDesign(.default)
      .dynamicTypeSize(.xSmall ... .accessibility3)
      .foregroundStyle(BuildWeekDesign.Signal.background)
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .frame(maxWidth: .infinity)
      .frame(minHeight: BuildWeekDesign.Metric.crisisAction)
      .background(
        BuildWeekDesign.Signal.support,
        in: RoundedRectangle(cornerRadius: 22, style: .continuous)
      )
    }
    .accessibilityLabel(
      practiceCallWasTested
        ? "Practice call checked"
        : "Practice call for \(contact.name)"
    )
    .accessibilityHint("Practice only. No phone call is placed.")
    .accessibilitySortPriority(3)
  }

  private var unavailablePhoneNotice: some View {
    Label {
      Text(
        relayContacts.count > 1
          ? "This contact cannot be called from this screen. Try Next contact."
          : "This contact cannot be called from this screen."
      )
      .fixedSize(horizontal: false, vertical: true)
    } icon: {
      Image(systemName: "phone.slash.fill")
    }
    .font(.body.weight(.semibold))
    .fontDesign(.default)
    .dynamicTypeSize(.xSmall ... .accessibility3)
    .foregroundStyle(BuildWeekDesign.Signal.ivory)
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      BuildWeekDesign.Signal.surface,
      in: RoundedRectangle(cornerRadius: 20, style: .continuous)
    )
    .accessibilityElement(children: .combine)
  }

  private func callURL(for contact: EmergencyContact) -> URL? {
    guard contact.hasCallablePhoneNumber else { return nil }

    let digits = contact.phone.filter { "0123456789".contains($0) }
    guard digits.count >= 3 else { return nil }

    let hasInternationalPrefix =
      contact.phone.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("+")
    let normalized = hasInternationalPrefix ? "+\(digits)" : digits
    return URL(string: "tel://\(normalized)")
  }

  private func advanceRelayContact() {
    guard !relayContacts.isEmpty else { return }
    activeRelayIndex = (activeRelayIndex + 1) % relayContacts.count
    if settings.shieldHapticsEnabled {
      impactGenerator.impactOccurred()
    }
  }

  private var debugContactsOverride: [EmergencyContact]? {
    #if DEBUG
      switch Self.debugScenarioName {
      case "no-contact", "long-copy", "qr":
        return []
      case "one-contact", "practice":
        return [Self.debugMaya]
      case "relay":
        return [Self.debugMaya, Self.debugJordan]
      case "invalid-phone":
        return [Self.debugInvalidContact]
      default:
        return nil
      }
    #else
      return nil
    #endif
  }

  private static func debugConfigOverride(_ base: ShieldConfig) -> ShieldConfig {
    #if DEBUG
      guard debugScenarioName == "long-copy" else { return base }
      return ShieldConfig(
        situationText:
          "I am safe, but speaking may be difficult. I need a quiet place, a little space, and time to settle before I can respond.",
        doText:
          "Speak softly and use short sentences. Give me space, keep the area quiet, and stay nearby without asking me to explain. Let me respond in my own time.",
        dontText:
          "Please do not touch or move me, crowd around me, speak loudly, or ask several questions at once unless I am in danger.",
        safetyText:
          "Call emergency services if I am injured, unconscious, having trouble breathing, or you believe there is an immediate danger to me or anyone nearby."
      )
    #else
      return base
    #endif
  }

  private static var debugInitialRelayIndex: Int {
    #if DEBUG
      let arguments = ProcessInfo.processInfo.arguments
      guard
        let flagIndex = arguments.firstIndex(of: "-shieldRelayIndex"),
        arguments.indices.contains(flagIndex + 1),
        let index = Int(arguments[flagIndex + 1])
      else {
        return 0
      }
      return max(0, index)
    #else
      return 0
    #endif
  }

  private static var debugShowsQRInitially: Bool {
    #if DEBUG
      return ProcessInfo.processInfo.arguments.contains("-showShieldQR")
        || debugScenarioName == "qr"
    #else
      return false
    #endif
  }

  private static var debugForcesPractice: Bool {
    #if DEBUG
      return debugScenarioName == "practice"
    #else
      return false
    #endif
  }

  #if DEBUG
    private static var debugScenarioName: String? {
      let arguments = ProcessInfo.processInfo.arguments
      if let flagIndex = arguments.firstIndex(of: "-shieldScenario"),
        arguments.indices.contains(flagIndex + 1)
      {
        return arguments[flagIndex + 1]
      }

      if arguments.contains("-shieldNoContact") { return "no-contact" }
      if arguments.contains("-shieldOneContact") { return "one-contact" }
      if arguments.contains("-shieldRelay") { return "relay" }
      if arguments.contains("-shieldInvalidPhone") { return "invalid-phone" }
      if arguments.contains("-shieldLongCopy") { return "long-copy" }
      if arguments.contains("-shieldQR") { return "qr" }
      return nil
    }

    private static let debugMaya = EmergencyContact(
      id: UUID(uuidString: "A4B40F57-1387-48B6-900B-57F071CA0001")!,
      name: "Maya",
      phone: "5550100"
    )

    private static let debugJordan = EmergencyContact(
      id: UUID(uuidString: "A4B40F57-1387-48B6-900B-57F071CA0002")!,
      name: "Jordan",
      phone: "5550110"
    )

    private static let debugInvalidContact = EmergencyContact(
      id: UUID(uuidString: "A4B40F57-1387-48B6-900B-57F071CA0003")!,
      name: "Sam",
      phone: "Unavailable"
    )
  #endif

  private func updateSystemServices() {
    brightness.applyEmergencyBrightness(enabled: settings.increaseBrightnessOnShieldCard)
    idleTimer.preventSleep(enabled: settings.preventScreenSleepOnShieldCard)
  }

  private func finish() {
    if isPractice {
      ShieldStorage.shared.practiceCount += 1
      ShieldStorage.shared.lastPracticeDate = Date()
    }
    engine.stop()
    dismiss()
  }
}

#Preview {
  BuildWeekShieldView(config: .defaults, isPractice: true)
    .environment(SettingsStore())
    .environmentObject(EmergencyContactStore())
}
