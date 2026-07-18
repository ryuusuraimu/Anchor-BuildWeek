import Foundation

enum OpenAIVoice: String, CaseIterable, Identifiable, Codable {
  case alloy
  case ash
  case ballad
  case coral
  case echo
  case fable
  case nova
  case onyx
  case sage
  case shimmer
  case verse
  case marin
  case cedar

  var id: String { rawValue }

  var displayName: String {
    rawValue.capitalized
  }

  var isRecommended: Bool {
    self == .marin || self == .cedar
  }
}

enum ShieldSpeechText {
  static func make(from config: ShieldConfig) -> String {
    [
      config.situationText,
      config.safetyText.map { "Safety. \($0)" },
      "What helps. \(config.doText)",
      "Please avoid. \(config.dontText)",
    ]
    .compactMap { $0 }
    .joined(separator: " ")
    .replacingOccurrences(of: "\n", with: " ")
  }
}
