import UIKit

@MainActor
final class BrightnessService {
  private var previous: CGFloat?

  func applyEmergencyBrightness(enabled: Bool) {
    guard enabled else { return }
    if previous == nil { previous = UIScreen.main.brightness }
    UIScreen.main.brightness = max(UIScreen.main.brightness, 0.95)
  }

  func restore() {
    guard let previous else { return }
    UIScreen.main.brightness = previous
    self.previous = nil
  }
}

@MainActor
final class IdleTimerService {
  private var previous: Bool?

  func preventSleep(enabled: Bool) {
    guard enabled else { return }
    if previous == nil { previous = UIApplication.shared.isIdleTimerDisabled }
    UIApplication.shared.isIdleTimerDisabled = true
  }

  func restore() {
    guard let previous else { return }
    UIApplication.shared.isIdleTimerDisabled = previous
    self.previous = nil
  }
}
