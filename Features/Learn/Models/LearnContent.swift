import SwiftUI

public enum LearnCategory: String, CaseIterable, Identifiable, Sendable {
  case helpingNow = "Helping Now"
  case communication = "Communication"
  case space = "Space"
  case safety = "Safety"
  case aftercare = "Aftercare"
  case usingAnchor = "Using Anchor"

  public var id: String { rawValue }
}

public struct LearnItem: Identifiable, Sendable {
  public let id = UUID()
  public let title: String
  public let category: LearnCategory
  public let when: String
  public let why: String
  public let todo: String
  public let sayThis: [String]
  public let icon: String
  public let color: Color
}

public struct LearnContent {
  public static let items: [LearnItem] = [
    // 1. Helping Now
    LearnItem(
      title: "First Response",
      category: .helpingNow,
      when: "They seem panicked, confused, frozen, or overwhelmed.",
      why: "Panic and overwhelm can look like confusion or freezing.",
      todo: "Check for immediate danger, then stay calm.",
      sayThis: ["I’m here with you.", "You are safe."],
      icon: "exclamationmark.bubble.fill",
      color: .teal
    ),
    LearnItem(
      title: "Grounding",
      category: .helpingNow,
      when: "They are hyperventilating or dissociated.",
      why: "Senses can pull attention back to the present.",
      todo: "Ask them to name things they see or hear.",
      sayThis: ["Can you see the floor?", "Listen to my voice."],
      icon: "eye.fill",
      color: .purple
    ),

    // 2. Communication
    LearnItem(
      title: "Less is More",
      category: .communication,
      when: "They are not responding or seem overwhelmed.",
      why: "Processing speed can slow down during stressful moments.",
      todo: "Use short, simple phrases. Wait for answers.",
      sayThis: ["Take your time.", "No need to rush."],
      icon: "waveform",
      color: .blue
    ),
    LearnItem(
      title: "Gentle Tone",
      category: .communication,
      when: "They seem scared or defensive.",
      why: "Tone conveys safety more than words.",
      todo: "Speak slowly, softly, and consistently.",
      sayThis: ["I am listening.", "It’s okay to be quiet."],
      icon: "mic.fill",
      color: .cyan
    ),

    // 3. Space
    LearnItem(
      title: "Physical Distance",
      category: .space,
      when: "They are backing away or flinching.",
      why: "Crowding triggers fight-or-flight response.",
      todo: "Step back. Keep an arm’s length or more.",
      sayThis: ["I’m giving you space.", "I’ll stay right here."],
      icon: "arrow.left.and.right",
      color: .orange
    ),
    LearnItem(
      title: "Reduce Stimulation",
      category: .space,
      when: "It is bright, loud, or crowded.",
      why: "Lights and noise can be painful.",
      todo: "Dim lights or move to a quieter corner.",
      sayThis: ["Let’s find a quiet spot.", "Let’s move to the shade."],
      icon: "light.min",
      color: .indigo
    ),

    // 4. Safety
    LearnItem(
      title: "Protect Dignity",
      category: .safety,
      when: "Others are staring or crowding.",
      why: "Staring can add shame and pressure.",
      todo: "Shield them from onlookers. Be a barrier.",
      sayThis: ["Just a moment, please.", "We need some privacy."],
      icon: "shield.fill",
      color: .red
    ),
    LearnItem(
      title: "No Touching",
      category: .safety,
      when: "You feel the urge to comfort them physically.",
      why: "Touch can feel like an attack.",
      todo: "Ask before touching, or avoid it entirely.",
      sayThis: ["I won’t touch you.", "Nod if you’d like help."],
      icon: "hand.raised.slash.fill",
      color: .pink
    ),

    // 5. Aftercare
    LearnItem(
      title: "Recovery Time",
      category: .aftercare,
      when: "The hard moment seems to be over.",
      why: "Adrenaline crash causes exhaustion.",
      todo: "Allow rest. Don't rush back to activity.",
      sayThis: ["Rest as long as you need.", "No pressure to talk."],
      icon: "clock.fill",
      color: .green
    ),
    LearnItem(
      title: "Hydration",
      category: .aftercare,
      when: "Their breathing has slowed down.",
      why: "Stress can consume physical energy.",
      todo: "Offer water when breathing slows.",
      sayThis: ["Here is some water.", "Take small sips."],
      icon: "drop.fill",
      color: .mint
    ),

    // 6. Using Anchor
    LearnItem(
      title: "Lock Screen Card",
      category: .usingAnchor,
      when: "You want the same instructions visible even when the phone is locked.",
      why: "When overwhelmed, unlocking and navigating can be high cognitive load. The lock screen card keeps the key message accessible.",
      todo: "Start Shield, then lock your iPhone to see the card (Now Playing). Use Next/Previous from the card to cycle.",
      sayThis: [],
      icon: "lock.fill",
      color: .teal
    ),
  ]

  public static var todayCard: LearnItem {
    // Deterministic daily rotation (day-of-year).
    let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
    let index = dayOfYear % items.count
    return items[index]
  }
}
