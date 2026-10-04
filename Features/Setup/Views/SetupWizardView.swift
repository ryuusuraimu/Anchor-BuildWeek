import SwiftUI

private enum OnboardingStep: Int, CaseIterable, Identifiable {
  case grounded
  case prepared
  case together
  case setup

  var id: Int { rawValue }

  var assetName: String {
    switch self {
    case .grounded: "OnboardingGrounded"
    case .prepared: "OnboardingPrepared"
    case .together: "OnboardingTogether"
    case .setup: "OnboardingTogether"
    }
  }

  var eyebrow: String {
    switch self {
    case .grounded: "A steady place"
    case .prepared: "Prepared words"
    case .together: "Support handoff"
    case .setup: "Make it reachable"
    }
  }

  var title: String {
    switch self {
    case .grounded: "When speaking feels hard, Anchor can speak for you."
    case .prepared: "Prepare a support card before the hard moment."
    case .together: "Help others understand what helps, quickly and kindly."
    case .setup: "Set up Anchor so it is ready when you need it."
    }
  }

  var subtitle: String {
    switch self {
    case .grounded:
      "Create calm, practical instructions for moments when explaining is difficult."
    case .prepared:
      "Your card can include what is happening, what helps, what to avoid, and who to contact."
    case .together:
      "Anchor is built around mutual support: one person prepares, another person can respond better."
    case .setup:
      "Add trusted contacts and choose a fast way to open your Shield."
    }
  }

  var symbol: String {
    switch self {
    case .grounded: "sparkles"
    case .prepared: "square.stack.3d.up"
    case .together: "hands.sparkles.fill"
    case .setup: "bolt.heart.fill"
    }
  }
}

struct SetupWizardView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  @State private var selectedStep: OnboardingStep = .grounded
  @State private var appeared = false

  @AppStorage("didSkipSetupWizard") private var didSkipSetupWizard = false
  @AppStorage("isSetupComplete") private var isSetupComplete = false

  var body: some View {
    ZStack {
      OnboardingBackground(step: selectedStep)
        .ignoresSafeArea()

      VStack(spacing: 0) {
        topBar

        TabView(selection: $selectedStep) {
          ForEach(OnboardingStep.allCases) { step in
            OnboardingPage(step: step, isActive: selectedStep == step)
              .tag(step)
          }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(maxHeight: .infinity)
        .animation(reduceMotion ? nil : .spring(response: 0.55, dampingFraction: 0.86), value: selectedStep)

        bottomControls
      }
      .opacity(appeared ? 1 : 0)
      .offset(y: appeared ? 0 : 18)
    }
    .buttonStyle(.plain)
    .onAppear {
      withAnimation(reduceMotion ? .linear(duration: 0.01) : .easeOut(duration: 0.7)) {
        appeared = true
      }
    }
  }

  private var topBar: some View {
    HStack {
      HStack(spacing: 8) {
        Image("AnchorSymbol", bundle: .main)
          .resizable()
          .scaledToFit()
          .frame(width: 26, height: 26)
          .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

        Text("Anchor")
          .font(.system(size: 18, weight: .bold, design: .rounded))
          .foregroundStyle(DesignSystem.Colors.deepText)
      }

      Spacer()

      if selectedStep != .setup {
        Button("Skip") {
          skipSetup()
        }
        .font(DesignSystem.Fonts.caption().weight(.semibold))
        .foregroundStyle(DesignSystem.Colors.softText)
        .frame(minWidth: DesignSystem.Layout.minTouchTarget, minHeight: DesignSystem.Layout.minTouchTarget)
      }
    }
    .padding(.horizontal, DesignSystem.Layout.screenPadding)
    .padding(.top, 12)
    .padding(.bottom, 4)
  }

  private var bottomControls: some View {
    VStack(spacing: 14) {
      ProgressPips(selectedStep: selectedStep)

      HStack(spacing: 12) {
        if selectedStep != .grounded {
          Button {
            goToPreviousStep()
          } label: {
            Image(systemName: "chevron.left")
              .font(.system(size: 17, weight: .bold))
              .foregroundStyle(DesignSystem.Colors.deepText)
              .frame(width: DesignSystem.Layout.minTouchTarget, height: DesignSystem.Layout.minTouchTarget)
              .background(Color.white.opacity(0.68), in: Circle())
              .overlay(Circle().stroke(DesignSystem.Colors.glassBorder, lineWidth: 1))
          }
          .accessibilityLabel("Back")
        }

        Button {
          goForward()
        } label: {
          HStack(spacing: 10) {
            Text(selectedStep == .setup ? "Start Using Anchor" : "Continue")
              .font(DesignSystem.Fonts.headline())
            Image(systemName: selectedStep == .setup ? "checkmark" : "arrow.right")
              .font(.system(size: 17, weight: .bold))
          }
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .frame(minHeight: 56)
          .background(
            LinearGradient(
              colors: [DesignSystem.Colors.calmTeal, DesignSystem.Colors.activeAction],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
          )
          .shadow(color: DesignSystem.Colors.calmTeal.opacity(0.26), radius: 18, x: 0, y: 10)
        }
      }
    }
    .padding(.horizontal, DesignSystem.Layout.screenPadding)
    .padding(.top, 10)
    .padding(.bottom, 20)
    .background(
      LinearGradient(
        colors: [Color.white.opacity(0.0), DesignSystem.Colors.offWhite.opacity(0.88)],
        startPoint: .top,
        endPoint: .bottom
      )
      .allowsHitTesting(false)
    )
  }

  private func goForward() {
    guard selectedStep != .setup else {
      completeSetup()
      return
    }

    let nextRawValue = min(selectedStep.rawValue + 1, OnboardingStep.setup.rawValue)
    if let next = OnboardingStep(rawValue: nextRawValue) {
      withAnimation(reduceMotion ? .linear(duration: 0.01) : .spring(response: 0.48, dampingFraction: 0.84)) {
        selectedStep = next
      }
    }
  }

  private func goToPreviousStep() {
    let previousRawValue = max(selectedStep.rawValue - 1, OnboardingStep.grounded.rawValue)
    if let previous = OnboardingStep(rawValue: previousRawValue) {
      withAnimation(reduceMotion ? .linear(duration: 0.01) : .spring(response: 0.48, dampingFraction: 0.84)) {
        selectedStep = previous
      }
    }
  }

  private func completeSetup() {
    isSetupComplete = true
    didSkipSetupWizard = false
    dismiss()
  }

  private func skipSetup() {
    didSkipSetupWizard = true
    dismiss()
  }
}

private struct OnboardingPage: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @EnvironmentObject private var contactStore: EmergencyContactStore

  let step: OnboardingStep
  let isActive: Bool

  @State private var float = false
  @State private var showQuickAccessOptions = false
  @State private var quickAccessSheet: QuickAccessSheet?
  @State private var contactDraft = EmergencyContactDraft()
  @State private var contactSheet: ContactSheet?

  private enum QuickAccessSheet: Identifiable {
    case backTap
    case actionButton

    var id: Int {
      switch self {
      case .backTap: 1
      case .actionButton: 2
      }
    }
  }

  private enum ContactSheet: Identifiable {
    case editor
    case picker

    var id: Int {
      switch self {
      case .editor: 1
      case .picker: 2
      }
    }
  }

  var body: some View {
    GeometryReader { proxy in
      let compact = proxy.size.height < 520
      let imageHeight = min(compact ? 214 : 258, max(184, proxy.size.height * 0.43))

      VStack(spacing: compact ? 12 : 16) {
        illustration(height: imageHeight)
          .padding(.top, compact ? 2 : 6)

        copyBlock(compact: compact)

        Group {
          if step == .setup {
            setupActions(compact: compact)
              .transition(.opacity.combined(with: .move(edge: .bottom)))
          } else {
            valueChips(compact: compact)
              .transition(.opacity.combined(with: .move(edge: .bottom)))
          }
        }
      }
      .padding(.horizontal, DesignSystem.Layout.screenPadding)
      .padding(.bottom, compact ? 6 : 12)
      .frame(maxWidth: .infinity)
      .frame(height: proxy.size.height, alignment: .top)
    }
    .onAppear { startMotion() }
    .onChange(of: isActive) { _, active in
      if active { startMotion() }
    }
    .confirmationDialog(
      "Quick Access",
      isPresented: $showQuickAccessOptions,
      titleVisibility: .visible
    ) {
      Button("Back Tap") { quickAccessSheet = .backTap }
      Button("Action Button") { quickAccessSheet = .actionButton }
      Button("Cancel", role: .cancel) {}
    } message: {
      Text("Choose the fastest way to open Anchor when you need it.")
    }
    .sheet(item: $quickAccessSheet) { sheet in
      switch sheet {
      case .backTap:
        BackTapGuideView()
      case .actionButton:
        ActionButtonGuideView()
      }
    }
    .sheet(item: $contactSheet) { sheet in
      switch sheet {
      case .editor:
        EmergencyContactEditor(
          draft: $contactDraft,
          isEditing: contactDraft.id != nil,
          onPickFromContacts: {
            contactSheet = .picker
          },
          onSave: {
            contactStore.upsert(contactDraft.toEmergencyContact())
            contactSheet = nil
          },
          onCancel: {
            contactSheet = nil
          },
          onRemove: (contactDraft.id != nil)
            ? {
              if let id = contactDraft.id {
                contactStore.remove(id: id)
              }
              contactSheet = nil
            } : nil
        )

      case .picker:
        ContactPicker(
          onSelect: { name, phone, label in
            contactDraft.name = name
            contactDraft.phone = phone
            contactDraft.phoneLabel = label ?? ""
            contactStore.upsert(contactDraft.toEmergencyContact())
            contactSheet = nil
          },
          onCancel: {
            contactSheet = .editor
          }
        )
      }
    }
  }

  private func illustration(height: CGFloat) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 32, style: .continuous)
        .fill(Color.white.opacity(0.58))
        .overlay(
          RoundedRectangle(cornerRadius: 32, style: .continuous)
            .stroke(Color.white.opacity(0.74), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.055), radius: 24, x: 0, y: 14)

      Image(step.assetName, bundle: .main)
        .resizable()
        .scaledToFill()
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .scaleEffect(isActive && !reduceMotion ? 1.035 : 1.0)
        .offset(y: float && isActive && !reduceMotion ? -5 : 0)
        .animation(.easeInOut(duration: 3.4).repeatForever(autoreverses: true), value: float)

      if step == .setup {
        VStack {
          Spacer()
          setupPreviewDock
        }
        .padding(18)
      }
    }
    .frame(height: height)
    .accessibilityHidden(true)
  }

  private var setupPreviewDock: some View {
    HStack(spacing: 10) {
      setupPreviewIcon("person.crop.circle.badge.plus", color: DesignSystem.Colors.warmCoral)
      setupPreviewIcon("hand.tap.fill", color: DesignSystem.Colors.calmTeal)
      setupPreviewIcon("shield.lefthalf.filled", color: DesignSystem.Colors.activeAction)
    }
    .padding(10)
    .background(.ultraThinMaterial, in: Capsule())
    .overlay(Capsule().stroke(Color.white.opacity(0.72), lineWidth: 1))
  }

  private func setupPreviewIcon(_ name: String, color: Color) -> some View {
    Image(systemName: name)
      .font(.system(size: 16, weight: .bold))
      .foregroundStyle(color)
      .frame(width: 40, height: 40)
      .background(Color.white.opacity(0.76), in: Circle())
  }

  private func copyBlock(compact: Bool) -> some View {
    VStack(spacing: compact ? 8 : 10) {
      Label(step.eyebrow, systemImage: step.symbol)
        .font(.system(size: compact ? 11 : 12, weight: .bold, design: .rounded))
        .foregroundStyle(DesignSystem.Colors.activeAction)
        .padding(.horizontal, 12)
        .frame(height: compact ? 30 : 34)
        .background(Color.white.opacity(0.66), in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.74), lineWidth: 1))

      Text(step.title)
        .font(.system(size: compact ? 24 : 28, weight: .bold, design: .rounded))
        .foregroundStyle(DesignSystem.Colors.deepText)
        .multilineTextAlignment(.center)
        .lineSpacing(1)
        .lineLimit(3)
        .minimumScaleFactor(0.76)
        .fixedSize(horizontal: false, vertical: true)

      Text(step.subtitle)
        .font(.system(size: compact ? 13 : 15, weight: .medium, design: .rounded))
        .foregroundStyle(DesignSystem.Colors.softText)
        .multilineTextAlignment(.center)
        .lineSpacing(2)
        .lineLimit(compact ? 3 : 4)
        .minimumScaleFactor(0.78)
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(.horizontal, 2)
    .opacity(isActive ? 1 : 0.25)
    .offset(y: isActive ? 0 : 12)
    .animation(reduceMotion ? nil : .easeOut(duration: 0.38), value: isActive)
  }

  private func valueChips(compact: Bool) -> some View {
    HStack(spacing: 10) {
      ForEach(chips, id: \.self) { chip in
        Text(chip)
          .font(.system(size: compact ? 11 : 12, weight: .semibold, design: .rounded))
          .foregroundStyle(DesignSystem.Colors.deepText)
          .lineLimit(1)
          .minimumScaleFactor(0.8)
          .padding(.horizontal, compact ? 10 : 12)
          .frame(height: compact ? 30 : 34)
          .background(Color.white.opacity(0.62), in: Capsule())
          .overlay(Capsule().stroke(DesignSystem.Colors.glassBorder, lineWidth: 1))
      }
    }
    .frame(maxWidth: .infinity)
  }

  private var chips: [String] {
    switch step {
    case .grounded: ["Calm", "Private", "Ready"]
    case .prepared: ["Situation", "Please do", "Safety"]
    case .together: ["Diversity", "Support", "Local"]
    case .setup: []
    }
  }

  private func setupActions(compact: Bool) -> some View {
    VStack(spacing: compact ? 8 : 10) {
      SetupActionRow(
        icon: "person.crop.circle.badge.plus",
        title: contactStore.contacts.isEmpty ? "Add Support Relay" : "\(contactStore.contacts.count) Contact\(contactStore.contacts.count == 1 ? "" : "s") Added",
        subtitle: contactStore.contacts.isEmpty ? "Choose trusted people for handoff" : "You can add or edit more later",
        accent: DesignSystem.Colors.warmCoral,
        compact: compact
      ) {
        openContactEditor()
      }

      SetupActionRow(
        icon: "hand.tap",
        title: "Set up Quick Access",
        subtitle: "Use Back Tap or the Action Button",
        accent: DesignSystem.Colors.calmTeal,
        compact: compact
      ) {
        showQuickAccessOptions = true
      }
    }
  }

  private func startMotion() {
    guard isActive, !reduceMotion else { return }
    float = false
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
      float = true
    }
  }

  private func openContactEditor() {
    contactDraft = EmergencyContactDraft(from: nil)
    contactSheet = .editor
  }
}

private struct ProgressPips: View {
  let selectedStep: OnboardingStep

  var body: some View {
    HStack(spacing: 8) {
      ForEach(OnboardingStep.allCases) { step in
        Capsule()
          .fill(step == selectedStep ? DesignSystem.Colors.activeAction : DesignSystem.Colors.softText.opacity(0.18))
          .frame(width: step == selectedStep ? 28 : 8, height: 8)
          .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedStep)
      }
    }
    .accessibilityLabel("Onboarding progress")
    .accessibilityValue("\(selectedStep.rawValue + 1) of \(OnboardingStep.allCases.count)")
  }
}

private struct OnboardingBackground: View {
  let step: OnboardingStep
  @State private var animate = false

  var body: some View {
    ZStack {
      DesignSystem.Colors.offWhite

      GeometryReader { proxy in
        Circle()
          .fill(primaryColor.opacity(0.42))
          .frame(width: proxy.size.width * 1.16)
          .offset(
            x: animate ? -proxy.size.width * 0.34 : -proxy.size.width * 0.46,
            y: animate ? -proxy.size.height * 0.22 : -proxy.size.height * 0.32
          )
          .blur(radius: 68)

        Circle()
          .fill(secondaryColor.opacity(0.42))
          .frame(width: proxy.size.width * 0.95)
          .offset(
            x: animate ? proxy.size.width * 0.45 : proxy.size.width * 0.33,
            y: animate ? proxy.size.height * 0.44 : proxy.size.height * 0.36
          )
          .blur(radius: 76)
      }
    }
    .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true), value: animate)
    .animation(.easeInOut(duration: 0.65), value: step)
    .onAppear { animate = true }
  }

  private var primaryColor: Color {
    switch step {
    case .grounded: DesignSystem.Colors.paleMint
    case .prepared: DesignSystem.Colors.skyBlue
    case .together: DesignSystem.Colors.warmCoral
    case .setup: DesignSystem.Colors.paleMint
    }
  }

  private var secondaryColor: Color {
    switch step {
    case .grounded: DesignSystem.Colors.skyBlue
    case .prepared: DesignSystem.Colors.warmCoral
    case .together: DesignSystem.Colors.paleMint
    case .setup: DesignSystem.Colors.calmTeal
    }
  }
}

private struct SetupActionRow: View {
  let icon: String
  let title: String
  let subtitle: String
  let accent: Color
  var compact: Bool = false
  let action: () -> Void

  @State private var pressed = false

  var body: some View {
    Button(action: action) {
      HStack(spacing: 14) {
        Image(systemName: icon)
          .font(.system(size: compact ? 16 : 18, weight: .semibold))
          .foregroundStyle(accent)
          .frame(width: compact ? 38 : 46, height: compact ? 38 : 46)
          .background(accent.opacity(0.12), in: Circle())

        VStack(alignment: .leading, spacing: 4) {
          Text(title)
            .font(.system(size: compact ? 15 : 18, weight: .semibold, design: .rounded))
            .foregroundStyle(DesignSystem.Colors.deepText)
            .lineLimit(2)
            .minimumScaleFactor(0.82)

          Text(subtitle)
            .font(.system(size: compact ? 11 : 13, weight: .medium, design: .rounded))
            .foregroundStyle(DesignSystem.Colors.softText)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
        }

        Spacer(minLength: 0)

        Image(systemName: "chevron.right")
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(DesignSystem.Colors.softText)
      }
      .padding(compact ? 12 : 16)
      .frame(maxWidth: .infinity)
      .background(Color.white.opacity(0.66), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
      .overlay(
        RoundedRectangle(cornerRadius: 20, style: .continuous)
          .stroke(DesignSystem.Colors.glassBorder, lineWidth: 1)
      )
      .shadow(color: Color.black.opacity(0.035), radius: 12, x: 0, y: 8)
      .scaleEffect(pressed ? 0.98 : 1.0)
      .animation(.spring(response: 0.25, dampingFraction: 0.85), value: pressed)
    }
    .buttonStyle(.plain)
    .onLongPressGesture(
      minimumDuration: 0.01,
      maximumDistance: 12,
      pressing: { isPressing in
        pressed = isPressing
      },
      perform: {}
    )
  }
}

struct SourcesSheetView: View {
  @Environment(\.dismiss) private var dismiss

  private let references: [Reference] = [
    Reference(
      title: "Design note",
      detail:
        "Anchor focuses on preparation and communication support for moments when speaking or deciding may be difficult."
    ),
    Reference(
      title: "Privacy note",
      detail: "Support cards, journal entries, and support contact information are stored locally on device."
    ),
    Reference(
      title: "Important note",
      detail:
        "Anchor is not a medical device, diagnosis tool, treatment tool, or emergency service."
    ),
  ]

  var body: some View {
    NavigationStack {
      ZStack {
        OrganicBackgroundView()
          .ignoresSafeArea()

        DesignSystem.Colors.offWhite
          .opacity(0.78)
          .ignoresSafeArea()

        ScrollView {
          VStack(alignment: .leading, spacing: 16) {
            GlassCard {
              VStack(alignment: .leading, spacing: 12) {
                Text("Notes")
                  .font(DesignSystem.Fonts.headline())
                  .foregroundStyle(DesignSystem.Colors.deepText)

                Text(
                  "Stress and sensory overload can temporarily make speaking and decision-making harder."
                )
                .font(DesignSystem.Fonts.body())
                .foregroundStyle(DesignSystem.Colors.softText)

                Divider().opacity(0.35)

                VStack(alignment: .leading, spacing: 8) {
                  Text("How Anchor frames support")
                    .font(DesignSystem.Fonts.headline())
                    .foregroundStyle(DesignSystem.Colors.deepText)

                  Text(
                    "Anchor helps you prepare short, practical instructions before a hard moment happens. It is meant to reduce communication friction, not to diagnose or treat a condition."
                  )
                  .font(DesignSystem.Fonts.body())
                  .foregroundStyle(DesignSystem.Colors.softText)

                  Text("This is preparation support, not medical advice.")
                    .font(DesignSystem.Fonts.caption())
                    .foregroundStyle(DesignSystem.Colors.softText)
                }
              }
            }

            Text("References")
              .font(DesignSystem.Fonts.headline())
              .foregroundStyle(DesignSystem.Colors.deepText)
              .padding(.horizontal, 4)

            VStack(spacing: 12) {
              ForEach(references) { ref in
                GlassCard {
                  VStack(alignment: .leading, spacing: 6) {
                    Text(ref.title)
                      .font(DesignSystem.Fonts.headline())
                      .foregroundStyle(DesignSystem.Colors.deepText)

                    Text(ref.detail)
                      .font(DesignSystem.Fonts.body())
                      .foregroundStyle(DesignSystem.Colors.softText)
                  }
                }
              }
            }
          }
          .padding(18)
        }
      }
      .navigationTitle("Sources")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Close") { dismiss() }
            .foregroundStyle(DesignSystem.Colors.warmCoral)
        }
      }
    }
  }
}

private struct Reference: Identifiable {
  let id = UUID()
  let title: String
  let detail: String
}
