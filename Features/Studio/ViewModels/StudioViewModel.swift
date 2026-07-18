import Foundation
import Observation

@Observable
@MainActor
class StudioViewModel {
  var config: ShieldConfig
  private var storage: ShieldStorage

  init(storage: ShieldStorage? = nil) {
    let resolved = storage ?? .shared
    self.storage = resolved
    self.config = resolved.config
  }

  // Removed updateTone as we now only have one default configuration

  /// Auto-save enabling persistence without creating history spam
  func persistCurrentState() {
    storage.config = config
    // No more drafts, just main config
  }

  /// Manual save creating a history entry
  func saveVersion(
    title: String? = nil, note: String? = nil, icon: String? = nil, themeColor: String? = nil
  ) {
    persistCurrentState()
    storage.saveHistory(
      config: config,
      title: title,
      note: note,
      icon: icon,
      themeColor: themeColor
    )
  }

  func restore(_ item: ShieldStorage.HistoryItem) {
    config = item.config
    persistCurrentState()  // Just update current, don't create new history entry for restore
  }
}
