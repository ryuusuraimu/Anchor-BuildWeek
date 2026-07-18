import Foundation
import Observation
import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
  case grounded
  case luminous

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .grounded: return "Grounded"
    case .luminous: return "Luminous"
    }
  }

  var detail: String {
    switch self {
    case .grounded: return "Deep mineral layers and a steady, quiet weight."
    case .luminous: return "A soft opaline field with more light and openness."
    }
  }

  var symbolName: String {
    switch self {
    case .grounded: return "water.waves"
    case .luminous: return "sparkles"
    }
  }

  var primaryColor: Color {
    switch self {
    case .grounded: return Color(hex: "D97759")
    case .luminous: return Color(hex: "E58C72")
    }
  }

  var backgroundColor: Color {
    switch self {
    case .grounded: return Color(hex: "091315")
    case .luminous: return Color(hex: "0B1120")
    }
  }
}

@Observable
@MainActor
final class SettingsStore {
  private var suppressPersistence = false

  private enum Key {
    static let increaseBrightnessOnShieldCard = "increaseBrightnessOnShieldCard"
    static let preventScreenSleepOnShieldCard = "preventScreenSleepOnShieldCard"
    static let legacyIncreaseBrightnessOnCrisisCard = "increaseBrightnessOnCrisisCard"
    static let legacyPreventScreenSleepOnCrisisCard = "preventScreenSleepOnCrisisCard"
    static let selectedTheme = "selectedTheme"

    static let shieldSpeechEnabled = "shieldSpeechEnabled"
    static let shieldHapticsEnabled = "shieldHapticsEnabled"
    static let shieldAutoCycleEnabled = "shieldAutoCycleEnabled"
    static let shieldCycleInterval = "shieldCycleInterval"
    static let selectedOpenAIVoice = "selectedOpenAIVoice"
    static let hasExportedPDF = "hasExportedPDF"
  }

  var shieldSpeechEnabled: Bool {
    didSet {
      guard !suppressPersistence else { return }
      UserDefaults.standard.set(shieldSpeechEnabled, forKey: Key.shieldSpeechEnabled)
    }
  }

  var shieldHapticsEnabled: Bool {
    didSet {
      guard !suppressPersistence else { return }
      UserDefaults.standard.set(shieldHapticsEnabled, forKey: Key.shieldHapticsEnabled)
    }
  }

  var shieldAutoCycleEnabled: Bool {
    didSet {
      guard !suppressPersistence else { return }
      UserDefaults.standard.set(shieldAutoCycleEnabled, forKey: Key.shieldAutoCycleEnabled)
    }
  }

  var shieldCycleInterval: Double {
    didSet {
      guard !suppressPersistence else { return }
      UserDefaults.standard.set(shieldCycleInterval, forKey: Key.shieldCycleInterval)
    }
  }

  var increaseBrightnessOnShieldCard: Bool {
    didSet {
      guard !suppressPersistence else { return }
      UserDefaults.standard.set(
        increaseBrightnessOnShieldCard, forKey: Key.increaseBrightnessOnShieldCard)
    }
  }

  var preventScreenSleepOnShieldCard: Bool {
    didSet {
      guard !suppressPersistence else { return }
      UserDefaults.standard.set(
        preventScreenSleepOnShieldCard, forKey: Key.preventScreenSleepOnShieldCard)
    }
  }

  var selectedTheme: AppTheme {
    didSet {
      guard !suppressPersistence else { return }
      UserDefaults.standard.set(selectedTheme.rawValue, forKey: Key.selectedTheme)
    }
  }

  var hasExportedPDF: Bool {
    didSet {
      guard !suppressPersistence else { return }
      UserDefaults.standard.set(hasExportedPDF, forKey: Key.hasExportedPDF)
    }
  }

  var selectedOpenAIVoice: OpenAIVoice {
    didSet {
      guard !suppressPersistence else { return }
      UserDefaults.standard.set(selectedOpenAIVoice.rawValue, forKey: Key.selectedOpenAIVoice)
    }
  }

  init() {
    let ud = UserDefaults.standard
    self.increaseBrightnessOnShieldCard =
      ud.object(forKey: Key.increaseBrightnessOnShieldCard) as? Bool
      ?? ud.object(forKey: Key.legacyIncreaseBrightnessOnCrisisCard) as? Bool
      ?? false
    self.preventScreenSleepOnShieldCard =
      ud.object(forKey: Key.preventScreenSleepOnShieldCard) as? Bool
      ?? ud.object(forKey: Key.legacyPreventScreenSleepOnCrisisCard) as? Bool
      ?? true

    self.shieldSpeechEnabled = ud.object(forKey: Key.shieldSpeechEnabled) as? Bool ?? true
    self.shieldHapticsEnabled = ud.object(forKey: Key.shieldHapticsEnabled) as? Bool ?? true
    self.shieldAutoCycleEnabled = ud.bool(forKey: Key.shieldAutoCycleEnabled)  // Default false

    // Fix: Use local variable to avoid reading 'self' before full initialization
    let savedInterval = ud.double(forKey: Key.shieldCycleInterval)
    self.shieldCycleInterval = savedInterval == 0 ? 5.0 : savedInterval

    let savedTheme = ud.string(forKey: Key.selectedTheme)
    if let savedTheme, let theme = AppTheme(rawValue: savedTheme) {
      self.selectedTheme = theme
    } else if savedTheme == "light" || savedTheme == "cream" {
      self.selectedTheme = .luminous
    } else {
      // Legacy system/dark values migrate to the lower-sensory Grounded theme.
      self.selectedTheme = .grounded
    }

    self.hasExportedPDF = ud.bool(forKey: Key.hasExportedPDF)
    self.selectedOpenAIVoice =
      OpenAIVoice(
        rawValue: ud.string(forKey: Key.selectedOpenAIVoice) ?? ""
      ) ?? .cedar
  }

  func resetForLocalDataClear() {
    let ud = UserDefaults.standard
    suppressPersistence = true
    for key in [
      Key.increaseBrightnessOnShieldCard,
      Key.preventScreenSleepOnShieldCard,
      Key.legacyIncreaseBrightnessOnCrisisCard,
      Key.legacyPreventScreenSleepOnCrisisCard,
      Key.selectedTheme,
      Key.shieldSpeechEnabled,
      Key.shieldHapticsEnabled,
      Key.shieldAutoCycleEnabled,
      Key.shieldCycleInterval,
      Key.selectedOpenAIVoice,
      Key.hasExportedPDF,
      "isSetupComplete",
      "didSkipSetupWizard",
      "didDismissLockScreenCardTip",
      "didShowDeployLockScreenToast",
    ] {
      ud.removeObject(forKey: key)
    }

    increaseBrightnessOnShieldCard = false
    preventScreenSleepOnShieldCard = true
    shieldSpeechEnabled = true
    shieldHapticsEnabled = true
    shieldAutoCycleEnabled = false
    shieldCycleInterval = 5.0
    selectedTheme = .grounded
    selectedOpenAIVoice = .cedar
    hasExportedPDF = false
    suppressPersistence = false
  }
}
