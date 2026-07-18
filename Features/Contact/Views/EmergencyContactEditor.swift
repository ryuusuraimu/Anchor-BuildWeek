import SwiftUI
import UIKit

struct EmergencyContactEditor: View {
  @Binding var draft: EmergencyContactDraft
  var isEditing: Bool

  /// Called when the user wants to pick from system Contacts.
  var onPickFromContacts: () -> Void

  /// Called when the user taps Save.
  var onSave: () -> Void

  /// Called when the user taps Cancel.
  var onCancel: () -> Void

  /// Called when the user taps Remove (only shown when `isEditing == true`).
  var onRemove: (() -> Void)?

  private var canSave: Bool {
    !draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      && !draft.phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        header
        form
        if isEditing {
          removeButton
        }
        Spacer(minLength: 0)
      }
      .navigationTitle(isEditing ? "Edit Support Contact" : "Add Support Contact")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { onCancel() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") { onSave() }
            .disabled(!canSave)
        }
      }
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(alignment: .center) {
        Text("Who can Anchor help you reach?")
          .font(.title3)
          .fontWeight(.semibold)
          .foregroundStyle(.secondary)

        Spacer()

        Button(action: onPickFromContacts) {
          Label("Contacts", systemImage: "person.crop.circle.badge.plus")
            .labelStyle(.titleAndIcon)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.tint)
      }

      Text("Select a contact, then choose their specific phone number.")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .padding(.horizontal, 20)
    .padding(.top, 16)
    .padding(.bottom, 10)
  }

  private var form: some View {
    VStack(spacing: 16) {
      GlassField(
        title: "NAME",
        placeholder: "Required",
        text: $draft.name,
        textContentType: .name
      )
      GlassField(
        title: "PHONE NUMBER",
        placeholder: "+1 555 0100",
        text: $draft.phone,
        keyboardType: .phonePad,
        textContentType: .telephoneNumber
      )
      GlassField(title: "NOTE (OPTIONAL)", placeholder: "e.g. Parent, Friend", text: $draft.note)
    }
    .padding(.horizontal, 20)
    .padding(.top, 6)
  }

  private var removeButton: some View {
    Button(role: .destructive) {
      onRemove?()
    } label: {
      Text("Remove Contact")
        .font(.headline)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }
    .buttonStyle(.bordered)
    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    .padding(.horizontal, 20)
    .padding(.top, 18)
  }

  // NOTE: Cancel is handled by the parent via the `onCancel` callback.
}

/// Minimal "glass" input to match the app's visual language.
private struct GlassField: View {
  var title: String
  var placeholder: String
  @Binding var text: String
  var keyboardType: UIKeyboardType = .default
  var textContentType: UITextContentType?

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.caption)
        .foregroundStyle(.secondary)
        .tracking(0.8)

      TextField(placeholder, text: $text)
        .keyboardType(keyboardType)
        .textContentType(textContentType)
        .textInputAutocapitalization(.words)
        .autocorrectionDisabled(true)
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
          RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }
  }
}
