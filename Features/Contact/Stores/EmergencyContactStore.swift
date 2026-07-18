import Combine
import Foundation

/// Stores the user's support relay contacts and persists them locally.
///
/// NOTE:
/// This store intentionally uses Combine's `ObservableObject` + `@Published`.
/// The UI uses `@EnvironmentObject` / `@ObservedObject`, which rely on Combine
/// change notifications. Mixing those wrappers with the Swift Observation
/// `@Observable` macro can lead to UI not refreshing after updates.
@MainActor
final class EmergencyContactStore: ObservableObject {
  private static let legacyStorageKey = "anchor.emergencyContact.v1"
  private static let storageKey = "anchor.supportContacts.v2"

  @Published var contacts: [EmergencyContact] = [] {
    willSet {
      objectWillChange.send()
    }
    didSet {
      Self.saveStandard(contacts)
    }
  }

  var contact: EmergencyContact? {
    get { contacts.first }
    set {
      if let newValue {
        if contacts.isEmpty {
          contacts = [newValue]
        } else {
          contacts[0] = newValue
        }
      } else {
        contacts = []
      }
    }
  }

  var isSet: Bool { !contacts.isEmpty }
  var relayCount: Int { contacts.count }

  init() {
    contacts = Self.loadStandard()
  }

  func clear() {
    contacts = []
    Self.clearPersistedData()
  }

  func upsert(_ contact: EmergencyContact) {
    if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
      contacts[index] = contact
    } else {
      contacts.append(contact)
    }
  }

  func remove(id: UUID) {
    contacts.removeAll { $0.id == id }
  }

  func move(fromOffsets source: IndexSet, toOffset destination: Int) {
    var updated = contacts
    let movingItems = source.map { updated[$0] }
    for index in source.sorted(by: >) {
      updated.remove(at: index)
    }
    let adjustedDestination = destination - source.filter { $0 < destination }.count
    updated.insert(contentsOf: movingItems, at: adjustedDestination)
    contacts = updated
  }

  func nextContact(after contact: EmergencyContact?) -> EmergencyContact? {
    guard !contacts.isEmpty else { return nil }
    guard let contact, let index = contacts.firstIndex(where: { $0.id == contact.id }) else {
      return contacts.first
    }
    return contacts[(index + 1) % contacts.count]
  }

  // MARK: - Persistence

  static func saveStandard(_ contacts: [EmergencyContact]) {
    do {
      if contacts.isEmpty {
        UserDefaults.standard.removeObject(forKey: storageKey)
      } else {
        let data = try JSONEncoder().encode(contacts)
        UserDefaults.standard.set(data, forKey: storageKey)
      }
    } catch {
      // Silently ignore; persistence is best-effort.
      // (The app should still function even if saving fails.)
    }
  }

  static func loadStandard() -> [EmergencyContact] {
    if let data = UserDefaults.standard.data(forKey: storageKey) {
      do {
        return try JSONDecoder().decode([EmergencyContact].self, from: data)
      } catch {
        UserDefaults.standard.removeObject(forKey: storageKey)
      }
    }

    guard let legacyData = UserDefaults.standard.data(forKey: legacyStorageKey) else { return [] }
    do {
      let legacyContact = try JSONDecoder().decode(EmergencyContact.self, from: legacyData)
      let contacts = [legacyContact]
      saveStandard(contacts)
      return contacts
    } catch {
      UserDefaults.standard.removeObject(forKey: legacyStorageKey)
      return []
    }
  }

  static func loadPrimaryContact() -> EmergencyContact? {
    loadStandard().first
  }

  static func clearPersistedData() {
    UserDefaults.standard.removeObject(forKey: storageKey)
    UserDefaults.standard.removeObject(forKey: legacyStorageKey)
  }
}
