import Foundation

struct EmergencyContact: Codable, Equatable, Identifiable {
  var id: UUID
  var name: String
  var phone: String
  var phoneLabel: String?
  var note: String?

  init(
    id: UUID = UUID(),
    name: String,
    phone: String,
    phoneLabel: String? = nil,
    note: String? = nil
  ) {
    self.id = id
    self.name = name
    self.phone = phone
    self.phoneLabel = phoneLabel
    self.note = note
  }

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case phone
    case phoneLabel
    case note
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
    name = try container.decode(String.self, forKey: .name)
    phone = try container.decode(String.self, forKey: .phone)
    phoneLabel = try container.decodeIfPresent(String.self, forKey: .phoneLabel)
    note = try container.decodeIfPresent(String.self, forKey: .note)
  }

  /// A deliberately permissive check for phone numbers from any region.
  /// It prevents an empty or punctuation-only number from becoming a dead
  /// Call action without rejecting short local and emergency numbers.
  var hasCallablePhoneNumber: Bool {
    phone.unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }.count >= 3
  }
}
