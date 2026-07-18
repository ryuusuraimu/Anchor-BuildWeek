import SwiftUI

// MARK: - Home Hero
struct HomeHeroView: View {
  let readinessScore: Double

  var body: some View {
    GeometryReader { geo in
      let minY = geo.frame(in: .global).minY

      ZStack {
        // Background Image
        if let uiImage = UIImage(named: "AnchorCalmIllustration", in: .module, compatibleWith: nil)
          ?? UIImage(named: "HomeHero.jpg", in: .module, compatibleWith: nil)
        {
          Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
            .frame(width: geo.size.width, height: 300 + (minY > 0 ? minY : 0))
            .clipped()
            .mask(
              LinearGradient(
                colors: [.black, .black, .black.opacity(0)], startPoint: .top, endPoint: .bottom)
            )
            .offset(y: minY > 0 ? -minY : 0)
        } else {
          Color.gray
            .frame(width: geo.size.width, height: 300 + (minY > 0 ? minY : 0))
            .offset(y: minY > 0 ? -minY : 0)
        }

        VStack(spacing: 8) {
          Text("No rush. I'm here with you.")
            .font(DesignSystem.Fonts.title())
            .foregroundColor(DesignSystem.Colors.deepText)
            .multilineTextAlignment(.center)
        }
        .padding(.top, 64)  // Keep padding for safe area
        .padding(.bottom, 32)
        .padding(.horizontal, 32)
        .frame(width: geo.size.width)  // Ensure text stays centered
      }
    }
    .frame(height: 300)  // Fixed height for the container to reserve space
    .frame(maxWidth: .infinity)
    .accessibilityElement(children: .combine)
  }
}
