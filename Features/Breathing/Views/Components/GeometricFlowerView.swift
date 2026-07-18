import SwiftUI

struct GeometricFlowerView: View {
  var scale: CGFloat
  var opacity: Double
  var color: Color
  var rotation: Double = 0

  private let petalCount = 12

  var body: some View {
    ZStack {
      ForEach(0..<petalCount, id: \.self) { index in
        Circle()
          .fill(color.opacity(opacity * 0.3))  // Low opacity for blending
          .frame(width: 150, height: 150)
          .offset(x: 75)  // Offset to create petal effect from center
          .rotationEffect(.degrees(Double(index) / Double(petalCount) * 360))
          .rotationEffect(.degrees(rotation))  // Continuous rotation
      }

      // Center glow
      Circle()
        .fill(color.opacity(opacity * 0.5))
        .frame(width: 100, height: 100)
        .blur(radius: 20)
    }
    .frame(width: 300, height: 300)  // Ensure frame covers the offset petals (150 circle + 75 offset * 2 sides = 300)
    .scaleEffect(scale)
    .drawingGroup()  // Performance optimization for complex blending
  }
}

#Preview {
  ZStack {
    Color.black.ignoresSafeArea()
    GeometricFlowerView(scale: 1.0, opacity: 1.0, color: .cyan)
  }
}
