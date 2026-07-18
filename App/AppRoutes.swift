import Foundation
import SwiftUI

enum AppRoutes {
  static let shield = "anchor://shield"
  static let practice = "anchor://practice"
  static let journal = "anchor://journal"

  @MainActor
  static func open(_ route: String) {
    if let url = URL(string: route) {
      UIApplication.shared.open(url)
    }
  }
}
