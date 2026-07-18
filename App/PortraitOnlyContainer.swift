import SwiftUI

/// Swift Playgrounds (iPad) sometimes allows rotation regardless of Info.plist / AppDelegate.
/// This container keeps the *experience* portrait-only by blocking interaction in landscape.
///
/// Notes:
/// - We avoid hard dependencies on private APIs.
/// - We do not rely on `exclude` rules or simulator-only checks.
struct PortraitOnlyContainer<Content: View>: View {
  private let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    GeometryReader { proxy in
      let isLandscape = proxy.size.width > proxy.size.height

      ZStack {
        content
          .frame(width: proxy.size.width, height: proxy.size.height)

        if isLandscape {
          // Block interaction + clearly communicate.
          Color.black.opacity(0.35)
            .ignoresSafeArea()

          VStack(spacing: 10) {
            Image(systemName: "iphone")
              .font(.system(size: 28, weight: .semibold))
            Text("Portrait only")
              .font(.headline)
            Text("Please rotate your iPad back to portrait.")
              .font(.subheadline)
              .multilineTextAlignment(.center)
              .foregroundStyle(.secondary)
          }
          .padding(18)
          .background(.ultraThinMaterial)
          .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
          .padding(.horizontal, 24)
        }
      }
    }
  }
}
