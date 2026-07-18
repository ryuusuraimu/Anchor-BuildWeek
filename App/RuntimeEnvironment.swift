import Foundation

#if canImport(UIKit)
  import UIKit
#endif

/// Runtime environment helpers.
///
/// Why runtime detection?
/// - In some toolchains / packaging setups, `#if targetEnvironment(simulator)` may not behave as expected.
/// - Using environment variables is reliable across Simulator vs device.
@MainActor
enum RuntimeEnvironment {
  static var isSimulator: Bool {
    // These keys are present on iOS Simulator, absent on real devices.
    let env = ProcessInfo.processInfo.environment
    return env["SIMULATOR_DEVICE_NAME"] != nil || env["SIMULATOR_UDID"] != nil
  }

  static var isIPhone: Bool {
    #if canImport(UIKit)
      return UIDevice.current.userInterfaceIdiom == .phone
    #else
      return false
    #endif
  }

  static var isIPad: Bool {
    #if canImport(UIKit)
      return UIDevice.current.userInterfaceIdiom == .pad
    #else
      return false
    #endif
  }
}
