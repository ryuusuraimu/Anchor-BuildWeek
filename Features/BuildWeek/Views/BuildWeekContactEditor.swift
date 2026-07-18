import SwiftUI
import UIKit

struct BuildWeekContactEditor: View {
  @Binding var draft: EmergencyContactDraft
  let isEditing: Bool
  let onPickFromContacts: () -> Void
  let onSave: () -> Void
  let onCancel: () -> Void
  let onRemove: (() -> Void)?

  @State private var confirmRemoval = false

  var body: some View {
    ZStack {
      BuildWeekDesign.HumanSignal.backgroundWarm
        .ignoresSafeArea()

      VStack(spacing: 0) {
        header

        ScrollView {
          VStack(alignment: .leading, spacing: 24) {
            introduction
            contactsButton

            VStack(spacing: 18) {
              HumanSignalInputField(
                title: "Name",
                placeholder: "Required",
                text: $draft.name,
                contentType: .name
              )

              HumanSignalInputField(
                title: "Phone number",
                placeholder: "+1 555 0100",
                text: $draft.phone,
                keyboardType: .phonePad,
                contentType: .telephoneNumber,
                capitalization: .never
              )

              HumanSignalInputField(
                title: "Relationship or note",
                placeholder: "Optional — for example, friend",
                text: $draft.note
              )
            }

            privacyNote

            if isEditing {
              removeButton
            }
          }
          .padding(.horizontal, BuildWeekDesign.Metric.screenPadding)
          .padding(.top, 22)
          .padding(.bottom, 44)
        }
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.hidden)
      }
    }
    .alert("Remove this support contact?", isPresented: $confirmRemoval) {
      Button("Remove", role: .destructive) {
        onRemove?()
      }
      Button("Keep", role: .cancel) {}
    } message: {
      Text("They will no longer appear in your Shield Support Relay.")
    }
  }

  private var introduction: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("SUPPORT RELAY")
        .font(.caption.weight(.bold))
        .fontDesign(.default)
        .tracking(1.35)
        .foregroundStyle(BuildWeekDesign.HumanSignal.coral)
        .dynamicTypeSize(.xSmall ... .accessibility2)

      Text(isEditing ? "Keep this person within reach." : "Who should Anchor offer to call?")
        .font(.largeTitle.weight(.regular))
        .fontDesign(.serif)
        .tracking(-0.7)
        .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
        .fixedSize(horizontal: false, vertical: true)
        .dynamicTypeSize(.xSmall ... .accessibility2)
        .accessibilityAddTraits(.isHeader)

      Text(
        isEditing
          ? "Update only what has changed."
          : "Choose one trusted person now. You can add others after saving."
      )
      .font(.body.weight(.medium))
      .fontDesign(.default)
      .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
      .fixedSize(horizontal: false, vertical: true)
    }
  }

  private var contactsButton: some View {
    Button(action: onPickFromContacts) {
      HStack(spacing: 14) {
        Image(systemName: "person.crop.circle.badge.plus")
          .font(.system(size: 20, weight: .semibold))
          .frame(width: 28)
          .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: 3) {
          Text("Choose from Contacts")
            .font(.body.bold())
          Text("You choose the exact phone number.")
            .font(.footnote.weight(.medium))
            .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
            .fixedSize(horizontal: false, vertical: true)
        }

        Spacer(minLength: 8)

        Image(systemName: "arrow.right")
          .font(.system(size: 15, weight: .bold))
          .accessibilityHidden(true)
      }
      .fontDesign(.default)
      .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
      .padding(.horizontal, 16)
      .padding(.vertical, 14)
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(minHeight: 62)
      .background(
        BuildWeekDesign.HumanSignal.seaGlass.opacity(0.14),
        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
      )
      .overlay {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .stroke(BuildWeekDesign.HumanSignal.line, lineWidth: 1)
      }
    }
    .buttonStyle(.plain)
    .dynamicTypeSize(.xSmall ... .accessibility2)
    .accessibilityHint("Opens Contacts so you can select one phone number")
  }

  private var privacyNote: some View {
    HStack(alignment: .top, spacing: 12) {
      Rectangle()
        .fill(BuildWeekDesign.HumanSignal.seaGlass)
        .frame(width: 3)
        .frame(minHeight: 44)

      VStack(alignment: .leading, spacing: 4) {
        Label("PRIVATE ON THIS DEVICE", systemImage: "lock.fill")
          .font(.caption2.bold())
          .fontDesign(.default)
          .tracking(1.05)
          .foregroundStyle(BuildWeekDesign.HumanSignal.ink)

        Text("This contact is shown only when you choose to open Support Relay.")
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

  private var removeButton: some View {
    Button(role: .destructive) {
      confirmRemoval = true
    } label: {
      Label("Remove this person", systemImage: "trash")
        .font(.body.bold())
        .fontDesign(.default)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 54)
        .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityHint("Asks for confirmation before removing this person")
  }

  private var header: some View {
    ViewThatFits(in: .horizontal) {
      HStack(spacing: 12) {
        cancelButton
        Spacer(minLength: 8)
        editorTitle
        Spacer(minLength: 8)
        saveButton
      }

      VStack(alignment: .leading, spacing: 10) {
        HStack {
          cancelButton
          Spacer(minLength: 12)
          saveButton
        }
        editorTitle
      }
    }
    .font(.body)
    .fontDesign(.default)
    .dynamicTypeSize(.xSmall ... .accessibility2)
    .frame(minHeight: 58)
    .padding(.horizontal, BuildWeekDesign.Metric.screenPadding)
    .padding(.vertical, 4)
    .background(BuildWeekDesign.HumanSignal.backgroundWarm)
    .overlay(alignment: .bottom) {
      Rectangle()
        .fill(BuildWeekDesign.HumanSignal.line)
        .frame(height: 1)
    }
  }

  private var cancelButton: some View {
    Button("Cancel", action: onCancel)
      .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
      .frame(minWidth: 44, minHeight: 44)
      .fixedSize(horizontal: true, vertical: true)
  }

  private var editorTitle: some View {
    Text(isEditing ? "Edit person" : "Trusted person")
      .font(.headline)
      .fontDesign(.serif)
      .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
      .fixedSize(horizontal: true, vertical: true)
  }

  private var saveButton: some View {
    Button("Save", action: onSave)
      .fontWeight(.bold)
      .foregroundStyle(
        draft.canSave
          ? BuildWeekDesign.HumanSignal.action
          : BuildWeekDesign.HumanSignal.secondaryInk.opacity(0.46)
      )
      .frame(minWidth: 44, minHeight: 44)
      .disabled(!draft.canSave)
      .fixedSize(horizontal: true, vertical: true)
      .accessibilityHint(
        draft.canSave
          ? "Saves this person to Support Relay"
          : "Enter a name and callable phone number first"
      )
  }
}

private struct HumanSignalInputField: View {
  let title: String
  let placeholder: String
  @Binding var text: String
  var keyboardType: UIKeyboardType = .default
  var contentType: UITextContentType?
  var capitalization: TextInputAutocapitalization = .words

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title.uppercased())
        .font(.caption.weight(.bold))
        .fontDesign(.default)
        .tracking(1.05)
        .foregroundStyle(BuildWeekDesign.HumanSignal.secondaryInk)
        .dynamicTypeSize(.xSmall ... .accessibility2)

      TextField(placeholder, text: $text)
        .font(.body.weight(.semibold))
        .fontDesign(.default)
        .foregroundStyle(BuildWeekDesign.HumanSignal.ink)
        .keyboardType(keyboardType)
        .textContentType(contentType)
        .textInputAutocapitalization(capitalization)
        .autocorrectionDisabled(true)
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 58)
        .background(BuildWeekDesign.HumanSignal.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
          RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(BuildWeekDesign.HumanSignal.line, lineWidth: 1)
        }
    }
  }
}

#Preview {
  BuildWeekContactEditor(
    draft: .constant(EmergencyContactDraft()),
    isEditing: false,
    onPickFromContacts: {},
    onSave: {},
    onCancel: {},
    onRemove: nil
  )
}
