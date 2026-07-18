import SwiftUI
import UIKit

/// A lightweight wrapper around `UIActivityViewController`.
///
/// We use this instead of `ShareLink` because Swift Playgrounds on iPad can
/// sometimes render the share UI incorrectly for in-view toolbar buttons.
struct ShareActivityView: UIViewControllerRepresentable {
  let activityItems: [Any]
  var applicationActivities: [UIActivity]? = nil

  func makeUIViewController(context: Context) -> UIActivityViewController {
    let controller = UIActivityViewController(
      activityItems: activityItems,
      applicationActivities: applicationActivities
    )

    // Prefer a sheet-style presentation on iPad to avoid tiny/empty popovers.
    controller.modalPresentationStyle = .pageSheet

    return controller
  }

  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    // No-op.
  }
}
