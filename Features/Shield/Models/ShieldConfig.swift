import Foundation

public struct ShieldConfig: Codable, Equatable, Sendable {
  public var situationText: String
  public var doText: String
  public var dontText: String
  public var safetyText: String?

  public init(
    situationText: String, doText: String, dontText: String,
    safetyText: String? = nil
  ) {
    self.situationText = situationText
    self.doText = doText
    self.dontText = dontText
    self.safetyText = safetyText
  }

  public static let defaults = ShieldConfig(
    situationText: "I am safe. I need a quiet moment. Speaking may be difficult right now.",
    doText:
      "Please give me space. Speak softly. Stay nearby and help keep others back. Just be present — I should settle in a few minutes.",
    dontText: "Please don’t touch me, ask lots of questions, or crowd around me.",
    safetyText:
      "Call emergency services if I’m injured, unconscious, having trouble breathing, or you believe I’m in danger."
  )
}
