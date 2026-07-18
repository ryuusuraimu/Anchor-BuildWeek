import Foundation

/// A UI-friendly draft model for editing an `EmergencyContact`.
///
/// We keep a draft at the parent level so we can switch between the editor and
/// the system contact picker without nesting modals (which can cause ContactsUI
/// view-service timeouts in Simulator).
struct EmergencyContactDraft: Equatable {
  var id: UUID?
  var name: String = ""
  var phone: String = ""
  var phoneLabel: String = ""
  var note: String = ""

  init(name: String = "", phone: String = "", note: String = "") {
    self.name = name
    self.phone = phone
    self.note = note
  }

  init(from existing: EmergencyContact?) {
    self.id = existing?.id
    self.name = existing?.name ?? ""
    self.phone = existing?.phone ?? ""
    self.phoneLabel = existing?.phoneLabel ?? ""
    self.note = existing?.note ?? ""
  }

  func toEmergencyContact() -> EmergencyContact {
    EmergencyContact(
      id: id ?? UUID(),
      name: name.trimmingCharacters(in: .whitespacesAndNewlines),
      phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
      phoneLabel: phoneLabel.isEmpty ? nil : phoneLabel,
      note: note.trimmingCharacters(in: .whitespacesAndNewlines))
  }

  var canSave: Bool {
    !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      && phone.unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }.count >= 3
  }
}
