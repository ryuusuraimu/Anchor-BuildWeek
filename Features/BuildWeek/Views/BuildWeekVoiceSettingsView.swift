import SwiftUI

struct BuildWeekVoiceSettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(SettingsStore.self) private var settings

  @State private var voiceLibrary = ShieldVoiceLibrary.shared
  @State private var cacheRevision = 0
  @State private var actionError: String?

  private var config: ShieldConfig {
    ShieldStorage.shared.config
  }

  private var isPrepared: Bool {
    _ = cacheRevision
    return debugShowsReady
      || voiceLibrary.hasPreparedShieldVoice(
        config: config,
        voice: settings.selectedOpenAIVoice
      )
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 28) {
          introduction
          voicePicker
          offlinePanel
          disclosure
        }
        .padding(.horizontal, BuildWeekDesign.Metric.screenPadding)
        .padding(.top, 12)
        .padding(.bottom, 36)
      }
      .scrollIndicators(.hidden)
      .background(BuildWeekDesign.HumanSignal.background.ignoresSafeArea())
      .navigationTitle("Voice & reading")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") { dismiss() }
            .fontWeight(.semibold)
        }
      }
    }
    .preferredColorScheme(.light)
    .onDisappear {
      voiceLibrary.stopPreview()
    }
  }

  private var introduction: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("A steady voice, prepared before you need it.")
        .font(.system(.title, design: .serif, weight: .regular))
        .tracking(-0.7)
        .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityAddTraits(.isHeader)

      Text(
        "Choose and save your Shield reading now. In a hard moment, it plays from this iPhone without waiting for a connection."
      )
      .font(.body)
      .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
      .fixedSize(horizontal: false, vertical: true)
    }
    .dynamicTypeSize(.xSmall ... .accessibility2)
  }

  private var voicePicker: some View {
    VStack(alignment: .leading, spacing: 12) {
      sectionLabel("Choose a voice")

      VStack(alignment: .leading, spacing: 14) {
        Group {
          if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 12) {
              voiceIdentity
              voiceMenu
            }
          } else {
            HStack(alignment: .center, spacing: 12) {
              voiceIdentity
              Spacer(minLength: 12)
              voiceMenu
            }
          }
        }

        Divider()
          .overlay(BuildWeekDesign.HumanSignal.line)

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
          .frame(maxWidth: .infinity, alignment: .leading)
          .frame(minHeight: 44)
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(voiceLibrary.isGenerating)

        Text("Preview uses a short sample. Its first play may need an internet connection.")
          .font(.footnote)
          .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
          .fixedSize(horizontal: false, vertical: true)
      }
      .padding(16)
      .background(BuildWeekDesign.HumanSignal.surface)
      .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .stroke(BuildWeekDesign.HumanSignal.line.opacity(0.88), lineWidth: 0.8)
      }
    }
  }

  private var offlinePanel: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack(alignment: .top, spacing: 12) {
        Image(systemName: isPrepared ? "checkmark.shield.fill" : "arrow.down.circle")
          .font(.system(size: 23, weight: .medium))
          .foregroundStyle(
            isPrepared
              ? BuildWeekDesign.HumanSignal.actionPressed
              : BuildWeekDesign.HumanSignal.secondaryInk
          )
          .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: 4) {
          Text(isPrepared ? "Ready offline" : "Not saved for Shield yet")
            .font(.headline)
            .foregroundStyle(BuildWeekDesign.HumanSignal.ink)

          Text(
            isPrepared
              ? "Your current Shield wording is saved on this iPhone in \(settings.selectedOpenAIVoice.displayName)."
              : "Create the full reading while you are calm and connected. Until then, Shield uses the device voice."
          )
          .font(.subheadline)
          .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
          .fixedSize(horizontal: false, vertical: true)
        }
      }

      Button {
        Task { await prepareShieldVoice() }
      } label: {
        HStack(spacing: 10) {
          if voiceLibrary.isGenerating {
            ProgressView()
              .tint(Color.white)
          } else {
            Image(systemName: isPrepared ? "arrow.clockwise" : "arrow.down")
          }

          Text(
            voiceLibrary.isGenerating
              ? "Creating voice…"
              : (isPrepared ? "Update offline reading" : "Create offline reading")
          )
          .font(.headline)
        }
        .foregroundStyle(Color(hex: "FAF7F0"))
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 54)
        .background(BuildWeekDesign.HumanSignal.action)
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
      }
      .buttonStyle(.plain)
      .disabled(voiceLibrary.isGenerating)

      if let message = actionError ?? voiceLibrary.errorMessage {
        Label(message, systemImage: "exclamationmark.circle")
          .font(.footnote)
          .foregroundStyle(Color(hex: "9B3D31"))
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .padding(16)
    .background(BuildWeekDesign.HumanSignal.surface)
    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .stroke(BuildWeekDesign.HumanSignal.line.opacity(0.88), lineWidth: 0.8)
    }
    .accessibilityElement(children: .contain)
  }

  private var voiceIdentity: some View {
    VStack(alignment: .leading, spacing: 3) {
      Text(settings.selectedOpenAIVoice.displayName)
        .font(.title3.weight(.semibold))
        .foregroundStyle(BuildWeekDesign.HumanSignal.ink)

      Text(
        settings.selectedOpenAIVoice.isRecommended
          ? "OpenAI voice · Recommended"
          : "OpenAI voice"
      )
      .font(.footnote)
      .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
    }
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
            systemImage: settings.selectedOpenAIVoice == voice
              ? "checkmark" : "waveform"
          )
        }
      }
    } label: {
      HStack(spacing: 6) {
        Text("Change")
        Image(systemName: "chevron.up.chevron.down")
          .font(.caption.weight(.bold))
          .accessibilityHidden(true)
      }
      .font(.subheadline.weight(.semibold))
      .foregroundStyle(BuildWeekDesign.HumanSignal.actionPressed)
      .padding(.horizontal, 13)
      .frame(minHeight: 44)
      .background(BuildWeekDesign.HumanSignal.action.opacity(0.1))
      .clipShape(Capsule())
    }
    .accessibilityLabel("Change OpenAI voice")
  }

  private var disclosure: some View {
    VStack(alignment: .leading, spacing: 8) {
      sectionLabel("About AI voice")

      Text(
        "The voice is AI-generated by OpenAI. Preview sends only the sample above. Create sends your prepared Shield wording. The saved audio stays on this iPhone and can be removed with Clear Local Data."
      )
      .font(.footnote)
      .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
      .fixedSize(horizontal: false, vertical: true)
    }
  }

  private func sectionLabel(_ title: String) -> some View {
    Text(title.uppercased())
      .font(.caption.weight(.bold))
      .tracking(1.1)
      .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
      .accessibilityAddTraits(.isHeader)
  }

  private func previewSelectedVoice() async {
    actionError = nil
    do {
      try await voiceLibrary.preview(settings.selectedOpenAIVoice)
    } catch {
      actionError = error.localizedDescription
    }
  }

  private func selectVoice(_ voice: OpenAIVoice) {
    voiceLibrary.stopPreview()
    actionError = nil
    settings.selectedOpenAIVoice = voice
    cacheRevision += 1
  }

  private func prepareShieldVoice() async {
    voiceLibrary.stopPreview()
    actionError = nil
    do {
      try await voiceLibrary.generateShieldVoice(
        config: config,
        voice: settings.selectedOpenAIVoice
      )
      cacheRevision += 1
    } catch {
      actionError = error.localizedDescription
    }
  }

  private var debugShowsReady: Bool {
    #if DEBUG
      ProcessInfo.processInfo.arguments.contains("-voiceScenarioReady")
    #else
      false
    #endif
  }
}

#Preview("Voice settings") {
  BuildWeekVoiceSettingsView()
    .environment(SettingsStore())
}
