import SwiftUI
import UIKit

struct OneMinuteAnchorView: View {
  @Environment(\.scenePhase) private var scenePhase
  @Environment(SettingsStore.self) private var settings
  @EnvironmentObject private var contactStore: EmergencyContactStore
  @State private var viewModel = StudioViewModel()
  @State private var voiceLibrary = ShieldVoiceLibrary.shared
  @State private var stepIndex = 0
  @State private var isComplete = false
  @State private var showShield = false
  @State private var contactDraft = EmergencyContactDraft()
  @State private var contactSheet: ContactSheet?
  @State private var didApplyInitialState = false
  @State private var voiceSyncError: String?
  @AccessibilityFocusState private var questionIsFocused: Bool
  @AppStorage("buildWeek.didCompleteOneMinuteAnchor") private var didCompletePreparation = false

  private enum Step: Int, CaseIterable {
    case situation
    case help
    case avoid
    case safety
    case support

    var eyebrow: String {
      switch self {
      case .situation: return "What is happening"
      case .help: return "What helps"
      case .avoid: return "What to avoid"
      case .safety: return "When to get urgent help"
      case .support: return "Who to contact"
      }
    }

    var title: String {
      switch self {
      case .situation: return "What should someone understand first?"
      case .help: return "What makes this moment easier?"
      case .avoid: return "What could make it worse?"
      case .safety: return "When should someone call emergency services?"
      case .support: return "Who should Anchor offer to call?"
      }
    }

  }

  private enum ContactSheet: Identifiable {
    case editor
    case picker

    var id: Int {
      switch self {
      case .editor: return 1
      case .picker: return 2
      }
    }
  }

  private var steps: [Step] { Step.allCases }
  private var currentStep: Step { steps[min(stepIndex, steps.count - 1)] }

  private var hasRequiredContent: Bool {
    [
      viewModel.config.situationText,
      viewModel.config.doText,
      viewModel.config.dontText,
      viewModel.config.safetyText ?? "",
    ].allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
  }

  private var canAdvance: Bool {
    switch currentStep {
    case .situation:
      return !viewModel.config.situationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    case .help:
      return !viewModel.config.doText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    case .avoid:
      return !viewModel.config.dontText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    case .safety:
      return !(viewModel.config.safetyText ?? "")
        .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    case .support:
      return true
    }
  }

  var body: some View {
    NavigationStack {
      ZStack {
        BuildWeekDesign.HumanSignal.backgroundWarm
          .ignoresSafeArea()

        VStack(spacing: 0) {
          header

          if isComplete {
            completionView
          } else {
            stepView
          }
        }
      }
      .toolbar(.hidden, for: .navigationBar)
      .fullScreenCover(isPresented: $showShield) {
        BuildWeekShieldView(config: viewModel.config, isPractice: true)
      }
      .sheet(item: $contactSheet) { sheet in
        contactSheetContent(sheet)
      }
      .onAppear {
        guard !didApplyInitialState else { return }
        didApplyInitialState = true
        isComplete = didCompletePreparation && hasRequiredContent
        applyDebugPresentation()
      }
      .onDisappear(perform: persistAndValidate)
      .onChange(of: scenePhase) { _, phase in
        if phase != .active {
          persistAndValidate()
        }
      }
      .onChange(of: viewModel.config) { _, _ in
        viewModel.persistCurrentState()
        if !hasRequiredContent {
          didCompletePreparation = false
        }
      }
      .onChange(of: stepIndex) { _, newValue in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          questionIsFocused = true
          UIAccessibility.post(
            notification: .announcement,
            argument: "Step \(newValue + 1) of \(steps.count)"
          )
        }
      }
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack(alignment: .firstTextBaseline, spacing: 16) {
        Text("Prepare")
          .font(.title2.weight(.medium))
          .fontDesign(.serif)
          .tracking(-0.3)
          .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
          .dynamicTypeSize(.xSmall ... .accessibility2)
          .accessibilityAddTraits(.isHeader)

        Spacer(minLength: 8)

        Text(isComplete ? "READY" : "\(stepIndex + 1) / \(steps.count)")
          .font(.caption.weight(.bold))
          .fontDesign(.monospaced)
          .tracking(1.1)
          .foregroundStyle(
            isComplete
              ? BuildWeekDesign.HumanSignal.action
              : BuildWeekDesign.HumanSignal.secondaryInk
          )
          .dynamicTypeSize(.xSmall ... .accessibility2)
      }

      if !isComplete {
        GeometryReader { proxy in
          ZStack(alignment: .leading) {
            Rectangle()
              .fill(BuildWeekDesign.HumanSignal.line.opacity(0.7))
              .frame(height: 1)

            Rectangle()
              .fill(BuildWeekDesign.HumanSignal.coral)
              .frame(
                width: proxy.size.width * CGFloat(stepIndex + 1) / CGFloat(steps.count),
                height: 3
              )
          }
        }
        .frame(height: 3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(stepIndex + 1) of \(steps.count)")
      } else {
        Rectangle()
          .fill(BuildWeekDesign.HumanSignal.seaGlass)
          .frame(height: 2)
          .accessibilityHidden(true)
      }
    }
    .padding(.horizontal, BuildWeekDesign.Metric.screenPadding)
    .padding(.top, 16)
    .padding(.bottom, 18)
  }

  private var stepView: some View {
    VStack(spacing: 0) {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          Text(currentStep.eyebrow.uppercased())
            .font(.caption.weight(.bold))
            .fontDesign(.default)
            .tracking(1.35)
            .foregroundStyle(BuildWeekDesign.HumanSignal.coral)
            .dynamicTypeSize(.xSmall ... .accessibility2)

          Text(currentStep.title)
            .font(.largeTitle.weight(.regular))
            .fontDesign(.serif)
            .tracking(-0.7)
            .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
            .fixedSize(horizontal: false, vertical: true)
            .dynamicTypeSize(.xSmall ... .accessibility2)
            .accessibilityFocused($questionIsFocused)

          stepContent

          clarityNote
        }
        .padding(.horizontal, BuildWeekDesign.Metric.screenPadding)
        .padding(.top, 4)
        .padding(.bottom, 28)
      }
      .scrollIndicators(.hidden)

      navigationBar
    }
  }

  private var clarityNote: some View {
    HStack(alignment: .top, spacing: 12) {
      Rectangle()
        .fill(BuildWeekDesign.HumanSignal.seaGlass)
        .frame(width: 3)
        .frame(minHeight: 48)

      VStack(alignment: .leading, spacing: 5) {
        Text(currentStep == .support ? "PRIVACY NOTE" : "CLARITY CHECK")
          .font(.caption2.weight(.bold))
          .fontDesign(.default)
          .tracking(1.2)
          .foregroundStyle(BuildWeekDesign.HumanSignal.ink)

        Text(stepGuidance)
          .font(.footnote.weight(.medium))
          .fontDesign(.default)
          .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      BuildWeekDesign.HumanSignal.seaGlass.opacity(0.16),
      in: RoundedRectangle(cornerRadius: 14, style: .continuous)
    )
    .accessibilityElement(children: .combine)
  }

  @ViewBuilder
  private var stepContent: some View {
    switch currentStep {
    case .situation:
      editorCard(
        binding: $viewModel.config.situationText,
        limit: 120,
        placeholder: "For example: I am safe. I need a quiet moment.",
        suggestions: [
          "I am safe. I need a quiet moment.",
          "I feel overwhelmed and need some space.",
          "I may not be able to speak clearly right now.",
        ]
      )

    case .help:
      editorCard(
        binding: $viewModel.config.doText,
        limit: 160,
        placeholder: "For example: Speak softly and give me space.",
        suggestions: [
          "Speak softly and give me space.",
          "Stay nearby without asking questions.",
          "Help keep the area quiet and count slow breaths with me.",
        ]
      )

    case .avoid:
      editorCard(
        binding: $viewModel.config.dontText,
        limit: 120,
        placeholder: "For example: Please do not touch me.",
        suggestions: [
          "Please do not touch me.",
          "Do not crowd me or ask many questions.",
          "Do not speak loudly or move me unless I am in danger.",
        ]
      )

    case .safety:
      editorCard(
        binding: safetyBinding,
        limit: 140,
        placeholder: "For example: Call if I am unconscious or cannot breathe.",
        suggestions: [
          "Call emergency services if I am unconscious or cannot breathe.",
          "Call if I am injured or you believe I am in immediate danger.",
          "Stay with me and call my support person first unless it is an emergency.",
        ]
      )

    case .support:
      supportRelayCard
    }
  }

  private var stepGuidance: String {
    switch currentStep {
    case .situation:
      return "Short, direct words are easiest for someone nearby to scan."
    case .help:
      return "Specific actions are easier to follow than general reassurance."
    case .avoid:
      return "Name only what could make the moment harder."
    case .safety:
      return "Use clear signs someone else can observe, such as breathing or consciousness."
    case .support:
      return "A trusted contact is optional. Your Shield still works without one."
    }
  }

  private func editorCard(
    binding: Binding<String>,
    limit: Int,
    placeholder: String,
    suggestions: [String]
  ) -> some View {
    VStack(alignment: .leading, spacing: 18) {
      ZStack(alignment: .topLeading) {
        if binding.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
          Text(placeholder)
            .font(.body.weight(.medium))
            .fontDesign(.default)
            .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
            .padding(.horizontal, 17)
            .padding(.vertical, 17)
            .allowsHitTesting(false)
        }

        TextEditor(text: limited(binding, to: limit))
          .font(.body.weight(.semibold))
          .fontDesign(.default)
          .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
          .scrollContentBackground(.hidden)
          .padding(.horizontal, 12)
          .padding(.vertical, 9)
          .frame(minHeight: 104)
      }
      .background(BuildWeekDesign.HumanSignal.surface)
      .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .stroke(BuildWeekDesign.HumanSignal.line, lineWidth: 1)
      }

      HStack {
        Text("Plain words are easiest to scan")
          .fontDesign(.default)
        Spacer(minLength: 8)
        Text("\(binding.wrappedValue.count)/\(limit)")
          .fontDesign(.monospaced)
      }
      .font(.caption.weight(.medium))
      .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
      .accessibilityElement(children: .combine)

      Text("CLEAR STARTING POINTS")
        .font(.caption2.bold())
        .fontDesign(.default)
        .tracking(1.15)
        .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)

      VStack(spacing: 10) {
        ForEach(suggestions, id: \.self) { suggestion in
          PrepareSuggestionRow(
            title: suggestion,
            isSelected: binding.wrappedValue == suggestion
          ) {
            binding.wrappedValue = suggestion
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
    }
  }

  private var supportRelayCard: some View {
    VStack(alignment: .leading, spacing: 16) {
      if contactStore.contacts.isEmpty {
        PrepareSurface {
          VStack(alignment: .leading, spacing: 12) {
            Text("No trusted person added yet")
              .font(.headline)
              .fontDesign(.default)
              .foregroundStyle(BuildWeekDesign.HumanSignal.ink)

            Text("This is optional. The Shield still works without a phone contact.")
              .font(.body.weight(.medium))
              .fontDesign(.default)
              .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
              .fixedSize(horizontal: false, vertical: true)
          }
        }
      } else {
        VStack(spacing: 10) {
          ForEach(Array(contactStore.contacts.enumerated()), id: \.element.id) { index, contact in
            Button {
              contactDraft = EmergencyContactDraft(from: contact)
              contactSheet = .editor
            } label: {
              PrepareSurface {
                HStack(spacing: 14) {
                  Text("\(index + 1)")
                    .font(.footnote.bold())
                    .fontDesign(.default)
                    .foregroundStyle(Color.white)
                    .frame(width: 38, height: 38)
                    .background(BuildWeekDesign.HumanSignal.action, in: Circle())

                  VStack(alignment: .leading, spacing: 3) {
                    Text(contact.name)
                      .font(.headline)
                      .fontDesign(.default)
                      .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
                    Text(
                      contact.hasCallablePhoneNumber
                        ? contact.phone : "Phone number needs attention"
                    )
                    .font(.footnote.weight(.medium))
                    .fontDesign(.default)
                    .foregroundStyle(
                      contact.hasCallablePhoneNumber
                        ? BuildWeekDesign.HumanSignal.secondaryInk
                        : BuildWeekDesign.HumanSignal.coral
                    )
                  }

                  Spacer(minLength: 0)

                  Image(systemName: "pencil")
                    .font(.body.bold())
                    .foregroundStyle(BuildWeekDesign.HumanSignal.action)
                }
              }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Edit \(contact.name), relay position \(index + 1)")
          }
        }
      }

      ViewThatFits(in: .horizontal) {
        HStack(spacing: 12) {
          contactPickerButton
          manualContactButton
        }

        VStack(spacing: 12) {
          contactPickerButton
          manualContactButton
        }
      }

      sensoryComfortCard
    }
  }

  private var contactPickerButton: some View {
    Button {
      contactDraft = EmergencyContactDraft(from: nil)
      contactSheet = .picker
    } label: {
      Label("Choose from Contacts", systemImage: "person.crop.circle.badge.plus")
        .font(.body.bold())
        .fontDesign(.default)
        .foregroundStyle(Color.white)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 54)
        .background(
          BuildWeekDesign.HumanSignal.action,
          in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
    }
    .buttonStyle(.plain)
  }

  private var manualContactButton: some View {
    Button {
      contactDraft = EmergencyContactDraft(from: nil)
      contactSheet = .editor
    } label: {
      Label("Enter manually", systemImage: "square.and.pencil")
        .font(.body.bold())
        .fontDesign(.default)
        .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 54)
        .overlay(
          RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(BuildWeekDesign.HumanSignal.ink, lineWidth: 1)
        )
    }
    .buttonStyle(.plain)
  }

  private var sensoryComfortCard: some View {
    PrepareSurface {
      VStack(alignment: .leading, spacing: 14) {
        VStack(alignment: .leading, spacing: 4) {
          Text("Sensory comfort")
            .font(.headline)
            .fontDesign(.default)
            .foregroundStyle(BuildWeekDesign.HumanSignal.ink)

          Text("Choose what feels safest when the Shield opens.")
            .font(.footnote.weight(.medium))
            .fontDesign(.default)
            .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
            .fixedSize(horizontal: false, vertical: true)
        }

        Toggle(
          "Gentle Shield haptics",
          isOn: Bindable(settings).shieldHapticsEnabled
        )
        Toggle(
          "Raise screen brightness",
          isOn: Bindable(settings).increaseBrightnessOnShieldCard
        )
      }
      .font(.body.weight(.semibold))
      .fontDesign(.default)
      .tint(BuildWeekDesign.HumanSignal.action)
    }
  }

  private var navigationBar: some View {
    HStack(spacing: 12) {
      if stepIndex > 0 {
        Button {
          viewModel.persistCurrentState()
          stepIndex -= 1
        } label: {
          Image(systemName: "arrow.left")
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
            .frame(minWidth: 56, minHeight: 56)
            .overlay(
              RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(BuildWeekDesign.HumanSignal.line, lineWidth: 1)
            )
        }
        .accessibilityLabel("Previous step")
      }

      Button(action: advance) {
        HStack {
          Text(currentStep == .support ? "Finish my Anchor" : "Continue")
            .font(.headline)
            .fontDesign(.default)
          Spacer()
          Image(systemName: currentStep == .support ? "checkmark" : "arrow.right")
            .font(.system(size: 16, weight: .bold))
        }
        .foregroundStyle(Color.white)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 56)
        .background(
          canAdvance
            ? BuildWeekDesign.HumanSignal.action
            : BuildWeekDesign.HumanSignal.line,
          in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
      }
      .buttonStyle(.plain)
      .disabled(!canAdvance)
      .accessibilityHint(
        canAdvance
          ? (currentStep == .support
            ? "Completes your preparation." : "Moves to the next question.")
          : "Add a short answer before continuing."
      )
    }
    .padding(.horizontal, BuildWeekDesign.Metric.screenPadding)
    .padding(.top, 10)
    .padding(.bottom, 8)
    .background(BuildWeekDesign.HumanSignal.backgroundWarm)
    .dynamicTypeSize(.xSmall ... .accessibility2)
  }

  private var completionView: some View {
    VStack(spacing: 0) {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          HStack(spacing: 10) {
            Circle()
              .fill(BuildWeekDesign.HumanSignal.coral)
              .frame(width: 9, height: 9)

            Rectangle()
              .fill(BuildWeekDesign.HumanSignal.seaGlass)
              .frame(width: 44, height: 2)

            Text("YOUR SIGNAL IS SET")
              .font(.caption2.bold())
              .fontDesign(.default)
              .tracking(1.2)
              .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
              .dynamicTypeSize(.xSmall ... .accessibility1)
          }

          Text("Your Anchor is ready.")
            .font(.largeTitle.weight(.regular))
            .fontDesign(.serif)
            .tracking(-0.7)
            .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)

          Text("The hard decisions are already made. Your Shield can now speak for you.")
            .font(.body.weight(.medium))
            .fontDesign(.default)
            .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
            .fixedSize(horizontal: false, vertical: true)

          PrepareSurface {
            VStack(alignment: .leading, spacing: 18) {
              reviewRow(
                title: "First message",
                text: viewModel.config.situationText
              )
              Divider().overlay(BuildWeekDesign.HumanSignal.line)
              reviewRow(title: "Please do", text: viewModel.config.doText)
              Divider().overlay(BuildWeekDesign.HumanSignal.line)
              reviewRow(title: "Please avoid", text: viewModel.config.dontText)
              Divider().overlay(BuildWeekDesign.HumanSignal.line)
              reviewRow(
                title: "Urgent help",
                text: viewModel.config.safetyText ?? ""
              )
            }
          }

          voicePreparationCard
        }
        .padding(.horizontal, BuildWeekDesign.Metric.screenPadding)
        .padding(.top, 4)
        .padding(.bottom, 24)
      }
      .scrollIndicators(.hidden)

      completionActions
    }
  }

  private var completionActions: some View {
    VStack(spacing: 10) {
      Button {
        showShield = true
      } label: {
        HStack(spacing: 14) {
          Image(systemName: "shield.fill")
            .font(.system(size: 17, weight: .bold))

          Text("Practice my Shield")
            .font(.headline)
            .fontDesign(.default)
            .fixedSize(horizontal: false, vertical: true)

          Spacer(minLength: 12)

          Image(systemName: "arrow.up.right")
            .font(.system(size: 16, weight: .bold))
        }
        .foregroundStyle(Color.white)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 58)
        .background(
          BuildWeekDesign.HumanSignal.action,
          in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
      }
      .buttonStyle(.plain)

      Button {
        didCompletePreparation = false
        isComplete = false
        stepIndex = 0
      } label: {
        Label("Edit my words", systemImage: "pencil")
          .font(.body.bold())
          .fontDesign(.default)
          .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
          .frame(maxWidth: .infinity, minHeight: 48)
          .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
              .stroke(BuildWeekDesign.HumanSignal.line, lineWidth: 1)
          )
      }
      .buttonStyle(.plain)
    }
    .padding(.horizontal, BuildWeekDesign.Metric.screenPadding)
    .padding(.top, 10)
    .padding(.bottom, 8)
    .background(BuildWeekDesign.HumanSignal.backgroundWarm)
    .dynamicTypeSize(.xSmall ... .accessibility2)
  }

  private var voicePreparationCard: some View {
    PrepareSurface {
      VStack(alignment: .leading, spacing: 14) {
        HStack(alignment: .top, spacing: 12) {
          Image(systemName: voiceIsPrepared ? "checkmark.circle.fill" : "waveform")
            .font(.system(size: 22, weight: .medium))
            .foregroundStyle(
              voiceIsPrepared
                ? BuildWeekDesign.HumanSignal.actionPressed
                : BuildWeekDesign.HumanSignal.secondaryInk
            )
            .accessibilityHidden(true)

          VStack(alignment: .leading, spacing: 4) {
            Text("Shield voice")
              .font(.headline)
              .foregroundStyle(BuildWeekDesign.HumanSignal.ink)

            Text(
              voiceIsPrepared
                ? "Saved offline in \(settings.selectedOpenAIVoice.displayName)."
                : "It will sync automatically when you finish editing."
            )
            .font(.footnote.weight(.medium))
            .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
            .fixedSize(horizontal: false, vertical: true)
          }

          Spacer(minLength: 8)
          voiceMenu
        }

        if voiceLibrary.isGenerating {
          HStack(spacing: 9) {
            ProgressView()
              .tint(BuildWeekDesign.HumanSignal.actionPressed)
            Text("Updating your offline reading…")
          }
          .font(.footnote.weight(.semibold))
          .foregroundStyle(BuildWeekDesign.HumanSignal.actionPressed)
        } else if voiceIsPrepared {
          Label("Ready without a connection", systemImage: "checkmark.shield.fill")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(BuildWeekDesign.HumanSignal.actionPressed)
        } else {
          Label("Shield will use the iOS voice until this is ready.", systemImage: "iphone")
            .font(.footnote.weight(.medium))
            .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
        }

        HStack(spacing: 12) {
          Button {
            Task { await previewSelectedVoice() }
          } label: {
            Label(
              voiceLibrary.previewingVoice == settings.selectedOpenAIVoice ? "Stop" : "Preview",
              systemImage: voiceLibrary.previewingVoice == settings.selectedOpenAIVoice
                ? "stop.fill" : "play.fill"
            )
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(BuildWeekDesign.HumanSignal.actionPressed)
            .frame(maxWidth: .infinity, minHeight: 44)
          }
          .disabled(voiceLibrary.isGenerating)

          if !voiceIsPrepared && !voiceLibrary.isGenerating {
            Button {
              Task { await syncPreparedVoice() }
            } label: {
              Label("Retry", systemImage: "arrow.clockwise")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BuildWeekDesign.HumanSignal.actionPressed)
                .frame(maxWidth: .infinity, minHeight: 44)
            }
          }
        }

        if let message = voiceSyncError ?? voiceLibrary.errorMessage {
          Label(message, systemImage: "exclamationmark.circle")
            .font(.footnote)
            .foregroundStyle(Color(hex: "9B3D31"))
            .fixedSize(horizontal: false, vertical: true)
        }
      }
    }
    .accessibilityElement(children: .contain)
  }

  private var voiceIsPrepared: Bool {
    voiceLibrary.hasPreparedShieldVoice(
      config: viewModel.config,
      voice: settings.selectedOpenAIVoice
    )
  }

  private var voiceMenu: some View {
    Menu {
      ForEach(OpenAIVoice.allCases) { voice in
        Button {
          selectVoice(voice)
        } label: {
          Label(
            voice.isRecommended
              ? "\(voice.displayName) — Recommended"
              : voice.displayName,
            systemImage: settings.selectedOpenAIVoice == voice ? "checkmark" : "waveform"
          )
        }
      }
    } label: {
      HStack(spacing: 6) {
        Text(settings.selectedOpenAIVoice.displayName)
        Image(systemName: "chevron.up.chevron.down")
          .font(.caption.weight(.bold))
          .accessibilityHidden(true)
      }
      .font(.subheadline.weight(.semibold))
      .foregroundStyle(BuildWeekDesign.HumanSignal.actionPressed)
      .padding(.horizontal, 12)
      .frame(minHeight: 44)
      .background(BuildWeekDesign.HumanSignal.action.opacity(0.1))
      .clipShape(Capsule())
    }
    .accessibilityLabel("Change Shield voice")
  }

  private func selectVoice(_ voice: OpenAIVoice) {
    guard settings.selectedOpenAIVoice != voice else { return }
    voiceLibrary.stopPreview()
    voiceSyncError = nil
    settings.selectedOpenAIVoice = voice
    Task { await syncPreparedVoice() }
  }

  private func previewSelectedVoice() async {
    voiceSyncError = nil
    do {
      try await voiceLibrary.preview(settings.selectedOpenAIVoice)
    } catch {
      voiceSyncError = error.localizedDescription
    }
  }

  private func syncPreparedVoice() async {
    guard hasRequiredContent else { return }
    voiceLibrary.stopPreview()
    voiceSyncError = nil
    do {
      try await voiceLibrary.generateShieldVoice(
        config: viewModel.config,
        voice: settings.selectedOpenAIVoice
      )
    } catch {
      voiceSyncError = error.localizedDescription
    }
  }

  private func reviewRow(title: String, text: String) -> some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(title.uppercased())
        .font(.caption2.bold())
        .fontDesign(.default)
        .tracking(1.15)
        .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
      Text(text)
        .font(.body.weight(.semibold))
        .fontDesign(.default)
        .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
        .fixedSize(horizontal: false, vertical: true)
    }
  }

  private var safetyBinding: Binding<String> {
    Binding(
      get: { viewModel.config.safetyText ?? "" },
      set: { viewModel.config.safetyText = $0.isEmpty ? nil : $0 }
    )
  }

  private func limited(_ binding: Binding<String>, to limit: Int) -> Binding<String> {
    Binding(
      get: { binding.wrappedValue },
      set: { binding.wrappedValue = String($0.prefix(limit)) }
    )
  }

  private func advance() {
    guard canAdvance else { return }
    viewModel.persistCurrentState()

    if currentStep == .support {
      let isReady = hasRequiredContent
      didCompletePreparation = isReady
      isComplete = isReady
      Task { await syncPreparedVoice() }
    } else {
      stepIndex += 1
    }
  }

  @ViewBuilder
  private func contactSheetContent(_ sheet: ContactSheet) -> some View {
    switch sheet {
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
          contactSheet = nil
        }
      )

    case .editor:
      BuildWeekContactEditor(
        draft: $contactDraft,
        isEditing: contactDraft.id != nil,
        onPickFromContacts: {
          contactSheet = .picker
        },
        onSave: {
          guard contactDraft.canSave else { return }
          contactStore.upsert(contactDraft.toEmergencyContact())
          contactSheet = nil
        },
        onCancel: {
          contactSheet = nil
        },
        onRemove: removeContactAction
      )
    }
  }

  private var removeContactAction: (() -> Void)? {
    guard let id = contactDraft.id else { return nil }
    return {
      contactStore.remove(id: id)
      contactSheet = nil
    }
  }

  private func persistAndValidate() {
    viewModel.persistCurrentState()
    if !hasRequiredContent {
      didCompletePreparation = false
      isComplete = false
    }
  }

  private func applyDebugPresentation() {
    #if DEBUG
      let arguments = ProcessInfo.processInfo.arguments

      if let flagIndex = arguments.firstIndex(of: "-prepareStep"),
        arguments.indices.contains(flagIndex + 1),
        let requestedStep = Int(arguments[flagIndex + 1])
      {
        isComplete = false
        stepIndex = min(max(requestedStep, 0), steps.count - 1)
      }

      if arguments.contains("-showPrepareComplete") {
        isComplete = true
      }

      if arguments.contains("-showContactEditor") {
        stepIndex = Step.support.rawValue
        contactDraft = EmergencyContactDraft(from: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
          contactSheet = .editor
        }
      }
    #endif
  }
}

private struct PrepareSurface<Content: View>: View {
  private let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    content
      .padding(18)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(BuildWeekDesign.HumanSignal.surface)
      .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .stroke(BuildWeekDesign.HumanSignal.line, lineWidth: 1)
      }
  }
}

private struct PrepareSuggestionRow: View {
  let title: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(alignment: .center, spacing: 14) {
        Text(title)
          .font(.body.weight(.semibold))
          .fontDesign(.default)
          .fixedSize(horizontal: false, vertical: true)

        Spacer(minLength: 8)

        Image(systemName: isSelected ? "checkmark" : "plus")
          .font(.system(size: 14, weight: .bold))
          .frame(width: 24, height: 24)
      }
      .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(minHeight: 58)
      .background(
        isSelected
          ? BuildWeekDesign.HumanSignal.seaGlass.opacity(0.18)
          : Color.clear,
        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
      )
      .overlay {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .stroke(
            isSelected
              ? BuildWeekDesign.HumanSignal.action
              : BuildWeekDesign.HumanSignal.line,
            lineWidth: isSelected ? 1.4 : 1
          )
      }
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
    .accessibilityHint(
      isSelected
        ? "This answer is selected."
        : "Replaces the current answer with this sentence."
    )
  }
}

#Preview {
  OneMinuteAnchorView()
    .environmentObject(EmergencyContactStore())
    .environmentObject(AppRouter.shared)
    .environment(SettingsStore())
}
