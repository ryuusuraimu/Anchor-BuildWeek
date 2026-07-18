import SwiftUI

struct DeployShieldButton: View {
  var showShield: Bool
  var onDeploy: () -> Void

  var body: some View {
    Button(action: onDeploy) {
      HStack(spacing: 16) {
        Image(systemName: "shield.fill")
          .font(.title2)
          .symbolEffect(.bounce, value: showShield)

        Text("Deploy Shield")
          .font(.title3)
          .fontWeight(.bold)
      }
      .foregroundColor(.white)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 20)
      .background(
        ZStack {
          // 1. Base Glass Material
          Rectangle().fill(.regularMaterial)

          // 2. Tint Gradient
          LinearGradient(
            colors: [
              DesignSystem.Colors.calmTeal.opacity(0.7),
              DesignSystem.Colors.calmTeal.opacity(0.9),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        }
      )
      .clipShape(RoundedRectangle(cornerRadius: 30))
      .overlay(
        // 3. Glossy Border & Inner Glow
        RoundedRectangle(cornerRadius: 30)
          .strokeBorder(
            LinearGradient(
              colors: [
                Color.white.opacity(0.8),
                Color.white.opacity(0.2),
                Color.white.opacity(0.1),
                DesignSystem.Colors.calmTeal.opacity(0.5),
              ],
              startPoint: .top,
              endPoint: .bottom
            ),
            lineWidth: 1.5
          )
      )
      .overlay(
        // 4. Specular Highlight (Gloss)
        GeometryReader { geo in
          RoundedRectangle(cornerRadius: 30)
            .fill(
              LinearGradient(
                colors: [
                  Color.white.opacity(0.3),
                  Color.white.opacity(0.0),
                ],
                startPoint: .top,
                endPoint: .bottom
              )
            )
            .frame(height: geo.size.height * 0.5)
            .mask(RoundedRectangle(cornerRadius: 30))
        }
        .allowsHitTesting(false)
      )
      .shadow(color: DesignSystem.Colors.calmTeal.opacity(0.5), radius: 20, x: 0, y: 10)
    }
    .buttonStyle(.plain)
    .accessibilityLabel("Deploy Shield")
    .accessibilityHint("Opens your prepared support card.")

  }
}
