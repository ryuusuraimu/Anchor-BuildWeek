import ContactsUI
import SwiftUI

struct ContactPicker: UIViewControllerRepresentable {
  var onSelect: @MainActor (String, String, String?) -> Void
  var onCancel: @MainActor () -> Void = {}

  func makeCoordinator() -> Coordinator { Coordinator(self) }

  func makeUIViewController(context: Context) -> CNContactPickerViewController {
    let picker = CNContactPickerViewController()
    picker.delegate = context.coordinator

    picker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")

    picker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
    picker.predicateForSelectionOfProperty = NSPredicate(
      format: "key == %@", CNContactPhoneNumbersKey)

    picker.predicateForSelectionOfContact = NSPredicate(value: false)

    return picker
  }

  func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {
    context.coordinator.parent = self
  }

  @MainActor
  class Coordinator: NSObject, CNContactPickerDelegate {
    nonisolated(unsafe) var parent: ContactPicker
    init(_ parent: ContactPicker) { self.parent = parent }

    nonisolated func contactPicker(
      _ picker: CNContactPickerViewController,
      didSelect contactProperty: CNContactProperty
    ) {
      guard contactProperty.key == CNContactPhoneNumbersKey,
        let number = contactProperty.value as? CNPhoneNumber
      else { return }

      let contact = contactProperty.contact
      let fullName = [contact.givenName, contact.familyName]
        .filter { !$0.isEmpty }
        .joined(separator: " ")

      let phoneNumber = number.stringValue
      let label = contactProperty.label.map {
        CNLabeledValue<NSString>.localizedString(forLabel: $0)
      }
      Task { @MainActor in
        parent.onSelect(fullName, phoneNumber, label)
      }
    }

    // fallback
    nonisolated func contactPicker(
      _ picker: CNContactPickerViewController,
      didSelect contact: CNContact
    ) {
      let fullName = [contact.givenName, contact.familyName]
        .filter { !$0.isEmpty }
        .joined(separator: " ")


      let phoneEntry =
        contact.phoneNumbers.first(where: { $0.label == CNLabelPhoneNumberMobile })
        ?? contact.phoneNumbers.first

      let phone = phoneEntry?.value.stringValue ?? ""
      let label = phoneEntry?.label.map { CNLabeledValue<NSString>.localizedString(forLabel: $0) }

      Task { @MainActor in
        parent.onSelect(fullName, phone, label)
      }
    }

    nonisolated func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
      Task { @MainActor in parent.onCancel() }
    }
  }
}
