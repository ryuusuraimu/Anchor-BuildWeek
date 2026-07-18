import SwiftUI

struct BuildWeekAftercareView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  let onOpenShield: () -> Void

  @State private var selectedFeeling: AftercareFeeling?
  @State private var note = ""
  @State private var didSave = false
  @FocusState private var noteIsFocused: Bool

  private enum AftercareFeeling: String, CaseIterable, Identifiable {
    case activated
    case drained
    case settled

    var id: String { rawValue }

    var title: String {
      switch self {
      case .activated: return "Still activated"
      case .drained: return "Drained"
      case .settled: return "More settled"
      }
    }

    var subtitle: String {
      switch self {
      case .activated: return "My body still needs quiet."
      case .drained: return "I need rest and fewer demands."
      case .settled: return "The intensity has come down."
      }
    }

    var mood: JournalMood {
      switch self {
      case .activated: return .anxious
      case .drained: return .tired
      case .settled: return .calm
      }
    }

    var fallbackNote: String {
      "Aftercare check-in: \(title)."
    }
  }

  var body: some View {
    ZStack {
      BuildWeekDesign.HumanSignal.backgroundWarm
        .ignoresSafeArea()

      if didSave {
        savedView
      } else {
        checkInView
      }
    }
    .safeAreaInset(edge: .top, spacing: 0) {
      modalHeader
    }
    .presentationBackground(BuildWeekDesign.HumanSignal.backgroundWarm)
    .onAppear(perform: applyDebugPresentation)
  }

  private var modalHeader: some View {
    HStack(spacing: 16) {
      Text("Check in")
        .font(.title2.weight(.medium))
        .fontDesign(.serif)
        .tracking(-0.3)
        .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
        .dynamicTypeSize(.xSmall ... .accessibility2)
        .accessibilityAddTraits(.isHeader)

      Spacer(minLength: 8)

      Button {
        dismiss()
      } label: {
        Image(systemName: "xmark")
          .font(.system(size: 15, weight: .bold))
          .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
          .frame(width: 44, height: 44)
          .background(BuildWeekDesign.HumanSignal.surface, in: Circle())
          .overlay {
            Circle()
              .stroke(BuildWeekDesign.HumanSignal.line, lineWidth: 1)
          }
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Close check in")
      .accessibilityHint("Closes without requiring a response")
    }
    .padding(.horizontal, BuildWeekDesign.Metric.screenPadding)
    .padding(.vertical, 10)
    .background(BuildWeekDesign.HumanSignal.backgroundWarm)
    .overlay(alignment: .bottom) {
      Rectangle()
        .fill(BuildWeekDesign.HumanSignal.line.opacity(0.72))
        .frame(height: 1)
    }
  }

  private var checkInView: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 26) {
        VStack(alignment: .leading, spacing: 12) {
          Text("AFTER A HARD MOMENT")
            .font(.caption.weight(.bold))
            .fontDesign(.default)
            .tracking(1.35)
            .foregroundStyle(BuildWeekDesign.HumanSignal.coral)
            .dynamicTypeSize(.xSmall ... .accessibility2)

          if dynamicTypeSize.isAccessibilitySize {
            shieldFallbackButton
          }

          aftercareTitle
          aftercareDescription

          if !dynamicTypeSize.isAccessibilitySize {
            shieldFallbackButton
          }
        }

        VStack(alignment: .leading, spacing: 12) {
          Text("How does your body feel now?")
            .font(.title3.weight(.medium))
            .fontDesign(.serif)
            .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
            .fixedSize(horizontal: false, vertical: true)

          feelingList
        }

        noteEditor

        Button(action: saveCheckIn) {
          HStack(spacing: 12) {
            Text("Save privately")
            Spacer(minLength: 12)
            Image(systemName: "lock.fill")
              .accessibilityHidden(true)
          }
          .font(.headline)
          .fontDesign(.default)
          .foregroundStyle(Color.white)
          .padding(.horizontal, 20)
          .frame(maxWidth: .infinity)
          .frame(minHeight: 60)
          .background(
            selectedFeeling == nil
              ? BuildWeekDesign.HumanSignal.line
              : BuildWeekDesign.HumanSignal.action,
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
          )
        }
        .buttonStyle(.plain)
        .disabled(selectedFeeling == nil)
        .dynamicTypeSize(.xSmall ... .accessibility2)
        .accessibilityHint(
          selectedFeeling == nil
            ? "Choose how your body feels first."
            : "Saves this check in only on this device."
        )

        privacyNote
      }
      .padding(.horizontal, BuildWeekDesign.Metric.screenPadding)
      .padding(.top, 20)
      .padding(.bottom, 44)
    }
    .scrollDismissesKeyboard(.interactively)
    .scrollIndicators(.hidden)
  }

  private var aftercareTitle: some View {
    Text("Nothing to solve right now.")
      .font(.largeTitle.weight(.regular))
      .fontDesign(.serif)
      .tracking(-0.7)
      .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
      .fixedSize(horizontal: false, vertical: true)
      .dynamicTypeSize(.xSmall ... .accessibility2)
      .accessibilityAddTraits(.isHeader)
  }

  private var aftercareDescription: some View {
    Text("Choose only what feels useful. You can close without recording anything.")
      .font(.body.weight(.medium))
      .fontDesign(.default)
      .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
      .fixedSize(horizontal: false, vertical: true)
  }

  private var shieldFallbackButton: some View {
    Button {
      dismiss()
      onOpenShield()
    } label: {
      HStack(spacing: 12) {
        Image(systemName: "shield.fill")
          .accessibilityHidden(true)
        Text("I still need my Shield")
        Spacer(minLength: 8)
        Image(systemName: "arrow.right")
          .accessibilityHidden(true)
      }
      .font(.body.bold())
      .fontDesign(.default)
      .foregroundStyle(Color.white)
      .padding(.horizontal, 18)
      .frame(maxWidth: .infinity)
      .frame(minHeight: 58)
      .background(
        BuildWeekDesign.HumanSignal.action,
        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
      )
    }
    .buttonStyle(.plain)
    .dynamicTypeSize(.xSmall ... .accessibility2)
    .accessibilityHint("Returns to your prepared Shield immediately")
  }

  private var feelingList: some View {
    VStack(spacing: 0) {
      ForEach(Array(AftercareFeeling.allCases.enumerated()), id: \.element.id) { index, feeling in
        feelingButton(feeling, number: index + 1)

        if index < AftercareFeeling.allCases.count - 1 {
          Divider()
            .overlay(BuildWeekDesign.HumanSignal.line)
            .padding(.leading, 58)
        }
      }
    }
    .background(BuildWeekDesign.HumanSignal.surface)
    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .stroke(BuildWeekDesign.HumanSignal.line, lineWidth: 1)
    }
  }

  private func feelingButton(_ feeling: AftercareFeeling, number: Int) -> some View {
    let isSelected = selectedFeeling == feeling

    return Button {
      selectedFeeling = feeling
    } label: {
      HStack(alignment: .center, spacing: 14) {
        Text(String(format: "%02d", number))
          .font(.caption.weight(.bold))
          .fontDesign(.monospaced)
          .foregroundStyle(
            isSelected
              ? BuildWeekDesign.HumanSignal.coral
              : BuildWeekDesign.HumanSignal.secondaryInk
          )
          .frame(width: 30)

        VStack(alignment: .leading, spacing: 3) {
          Text(feeling.title)
            .font(.body.bold())
          Text(feeling.subtitle)
            .font(.footnote.weight(.medium))
            .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
            .fixedSize(horizontal: false, vertical: true)
        }
        .fontDesign(.default)
        .foregroundStyle(BuildWeekDesign.HumanSignal.ink)

        Spacer(minLength: 8)

        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
          .font(.system(size: 20, weight: .semibold))
          .foregroundStyle(
            isSelected
              ? BuildWeekDesign.HumanSignal.action
              : BuildWeekDesign.HumanSignal.secondaryInk
          )
          .accessibilityHidden(true)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 14)
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(minHeight: 64)
      .background(
        isSelected
          ? BuildWeekDesign.HumanSignal.seaGlass.opacity(0.16)
          : Color.clear
      )
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityLabel("\(feeling.title). \(feeling.subtitle)")
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }

  private var noteEditor: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .firstTextBaseline) {
        Text("One sentence")
          .font(.title3.weight(.medium))
          .fontDesign(.serif)
          .foregroundStyle(BuildWeekDesign.HumanSignal.ink)

        Spacer(minLength: 8)

        Text("OPTIONAL")
          .font(.caption2.weight(.bold))
          .fontDesign(.default)
          .tracking(1.05)
          .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
      }

      ZStack(alignment: .topLeading) {
        if note.isEmpty {
          Text("Only if writing helps.")
            .font(.body)
            .fontDesign(.default)
            .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
            .padding(.horizontal, 17)
            .padding(.vertical, 17)
            .allowsHitTesting(false)
        }

        TextEditor(text: $note)
          .font(.body.weight(.medium))
          .fontDesign(.default)
          .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
          .scrollContentBackground(.hidden)
          .padding(10)
          .frame(minHeight: 108)
          .focused($noteIsFocused)
      }
      .background(BuildWeekDesign.HumanSignal.surface)
      .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .stroke(BuildWeekDesign.HumanSignal.line, lineWidth: 1)
      }
    }
  }

  private var privacyNote: some View {
    HStack(alignment: .top, spacing: 12) {
      Rectangle()
        .fill(BuildWeekDesign.HumanSignal.seaGlass)
        .frame(width: 3)
        .frame(minHeight: 42)

      VStack(alignment: .leading, spacing: 4) {
        Label("OPTIONAL AND PRIVATE", systemImage: "lock.fill")
          .font(.caption2.bold())
          .fontDesign(.default)
          .tracking(1.05)
          .foregroundStyle(BuildWeekDesign.HumanSignal.ink)

        Text("This check in stays on your device and is never required.")
          .font(.footnote.weight(.medium))
          .fontDesign(.default)
          .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      BuildWeekDesign.HumanSignal.seaGlass.opacity(0.14),
      in: RoundedRectangle(cornerRadius: 14, style: .continuous)
    )
    .accessibilityElement(children: .combine)
  }

  private var savedView: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        Spacer(minLength: dynamicTypeSize.isAccessibilitySize ? 32 : 88)

        HStack(spacing: 10) {
          Circle()
            .fill(BuildWeekDesign.HumanSignal.coral)
            .frame(width: 9, height: 9)

          Rectangle()
            .fill(BuildWeekDesign.HumanSignal.seaGlass)
            .frame(width: 44, height: 2)

          Text("CHECK IN SAVED")
            .font(.caption2.bold())
            .fontDesign(.default)
            .tracking(1.15)
            .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
            .dynamicTypeSize(.xSmall ... .accessibility1)
        }

        Text("That is enough.")
          .font(.largeTitle.weight(.regular))
          .fontDesign(.serif)
          .tracking(-0.7)
          .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
          .fixedSize(horizontal: false, vertical: true)
          .dynamicTypeSize(.xSmall ... .accessibility2)
          .accessibilityAddTraits(.isHeader)

        Text("Your private check in was saved on this device. Nothing else is required.")
          .font(.title3.weight(.medium))
          .fontDesign(.default)
          .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
          .fixedSize(horizontal: false, vertical: true)

        Button("Done") {
          dismiss()
        }
        .font(.headline)
        .fontDesign(.default)
        .foregroundStyle(Color.white)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 60)
        .background(
          BuildWeekDesign.HumanSignal.action,
          in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .buttonStyle(.plain)
        .dynamicTypeSize(.xSmall ... .accessibility2)
      }
      .padding(BuildWeekDesign.Metric.screenPadding)
      .padding(.bottom, 40)
    }
    .scrollIndicators(.hidden)
  }

  private func saveCheckIn() {
    guard let selectedFeeling else { return }
    let cleanNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
    JournalStorage.shared.addEntry(
      text: cleanNote.isEmpty ? selectedFeeling.fallbackNote : cleanNote,
      mood: selectedFeeling.mood
    )
    noteIsFocused = false
    didSave = true
  }

  private func applyDebugPresentation() {
    #if DEBUG
      let arguments = ProcessInfo.processInfo.arguments
      if arguments.contains("-showAftercareSaved") {
        selectedFeeling = .settled
        didSave = true
      } else if arguments.contains("-selectAftercareSettled") {
        selectedFeeling = .settled
      }
    #endif
  }
}

#Preview {
  BuildWeekAftercareView(onOpenShield: {})
}
