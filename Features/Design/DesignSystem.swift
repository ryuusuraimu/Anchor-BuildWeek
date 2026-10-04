import SwiftUI

// MARK: - Core Design System
struct DesignSystem {
  struct Colors {
    // Soft Neutrals
    static let offWhite = Color(hex: "FDFCF8")  // Warm Cream
    static let glassSurface = Color.white.opacity(0.84)  // Frosted Glass
    static let glassBorder = Color.white.opacity(0.62)

    // Accents (Calm & Premium)
    static let calmTeal = Color(hex: "4E8D99")  // Muted Teal
    static let warmCoral = Color(hex: "E8927C")  // Soft Coral
    static let deepText = Color(hex: "2D3142")  // Charcoal Blue
    static let softText = Color(hex: "6F7585")  // Accessible cool gray
    static let activeAction = Color(hex: "3A6F78")  // Darker Teal for active states

    // Organic/Pastel Accents (2026 Trend)
    static let shadowBlue = Color(hex: "8FA2B6")  // Soft Blue-Grey for shadows
    static let paleMint = Color(hex: "E0F2F1")  // Very light mint
    static let softCream = Color(hex: "FAFAF5")  // Warmer than offWhite
    static let skyBlue = Color(hex: "E1F5FE")  // Very light blue
    static let soft = ShadowStyle(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    static let floating = ShadowStyle(
      color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
    static func glow(color: Color) -> ShadowStyle {
      ShadowStyle(color: color.opacity(0.3), radius: 15, x: 0, y: 0)
    }
  }

  struct Fonts {
    static func hero() -> Font { .system(size: 34, weight: .bold, design: .rounded) }
    static func title() -> Font { .system(size: 22, weight: .semibold, design: .rounded) }
    static func headline() -> Font {
      .system(size: 18, weight: .semibold, design: .rounded)
    }
    static func body() -> Font { .system(size: 16, weight: .medium, design: .rounded) }
    static func caption() -> Font { .system(size: 13, weight: .medium, design: .rounded) }
  }

  struct Layout {
    static let screenPadding: CGFloat = 24
    static let compactScreenPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 24
    static let cardSpacing: CGFloat = 16
    static let minTouchTarget: CGFloat = 44
  }
}

// MARK: - Components

struct GlassCard<Content: View>: View {
  var content: Content
  var material: Material
  var tintOpacity: Double
  var borderOpacity: Double
  var shadowOpacity: Double

  init(
    material: Material = .ultraThinMaterial,
    tintOpacity: Double = 0.2,
    borderOpacity: Double = 1.0,
    shadowOpacity: Double = 0.03,
    @ViewBuilder content: () -> Content
  ) {
    self.material = material
    self.tintOpacity = tintOpacity
    self.borderOpacity = borderOpacity
    self.shadowOpacity = shadowOpacity
    self.content = content()
  }

  var body: some View {
    content
      .padding(20)
      .background(material)
      .overlay(Color.white.opacity(tintOpacity).allowsHitTesting(false))
      .cornerRadius(24)
      .overlay(
        RoundedRectangle(cornerRadius: 24)
          .stroke(DesignSystem.Colors.glassBorder.opacity(borderOpacity), lineWidth: 1)
          .allowsHitTesting(false)
      )
      .shadow(color: Color.black.opacity(shadowOpacity), radius: 15, x: 0, y: 10)
  }
}

struct OrganicBackgroundView: View {
  var colors: [Color] = [
    DesignSystem.Colors.paleMint,
    DesignSystem.Colors.skyBlue,
    DesignSystem.Colors.softCream,
  ]
  @State private var animate = false

  var body: some View {
    ZStack {
      DesignSystem.Colors.offWhite.ignoresSafeArea()

      GeometryReader { proxy in
        ZStack {
          // Blur 1
          Circle()
            .fill(colors[0].opacity(0.6))
            .frame(width: proxy.size.width * 1.2, height: proxy.size.width * 1.2)
            .scaleEffect(animate ? 1.05 : 1.0)
            .offset(x: -proxy.size.width * 0.3, y: -proxy.size.height * 0.4)
            .blur(radius: 80)

          // Blur 2
          Circle()
            .fill(colors[1].opacity(0.5))
            .frame(width: proxy.size.width * 1.0, height: proxy.size.width * 1.0)
            .scaleEffect(animate ? 1.1 : 0.95)
            .offset(x: proxy.size.width * 0.4, y: -proxy.size.height * 0.5)
            .blur(radius: 60)

          // Blur 3 (if available)
          if colors.count > 2 {
            Circle()
              .fill(colors[2].opacity(0.8))
              .frame(width: proxy.size.width * 0.8, height: proxy.size.width * 0.8)
              .scaleEffect(animate ? 0.95 : 1.05)
              .offset(x: 0, y: -proxy.size.height * 0.6)
              .blur(radius: 50)
          }
        }
        // Make sure the background never affects parent layout during rotation.
        .frame(width: proxy.size.width, height: proxy.size.height)
        .clipped()
        .ignoresSafeArea()
      }
    }
    .onAppear {
      withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
        animate.toggle()
      }
    }
    .allowsHitTesting(false)
  }
}

struct NoSelectionButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .contentShape(Rectangle())
  }
}

struct AnchorIllustrationPanel: View {
  var title: String
  var subtitle: String
  var icon: String = "anchor"
  var minHeight: CGFloat = 150

  var body: some View {
    ZStack(alignment: .bottomLeading) {
      Image("AnchorCalmIllustration", bundle: .main)
        .resizable()
        .scaledToFill()
        .frame(maxWidth: .infinity, minHeight: minHeight, maxHeight: minHeight)
        .clipped()

      LinearGradient(
        colors: [
          Color.white.opacity(0.0),
          Color.white.opacity(0.72),
          Color.white.opacity(0.96),
        ],
        startPoint: .top,
        endPoint: .bottom
      )

      HStack(alignment: .bottom, spacing: 12) {
        Image(systemName: icon)
          .font(.system(size: 17, weight: .semibold))
          .foregroundStyle(DesignSystem.Colors.activeAction)
          .frame(width: 38, height: 38)
          .background(
            Circle()
              .fill(Color.white.opacity(0.82))
          )
          .overlay(
            Circle()
              .stroke(Color.white.opacity(0.9), lineWidth: 1)
          )

        VStack(alignment: .leading, spacing: 4) {
          Text(title)
            .font(DesignSystem.Fonts.headline())
            .foregroundStyle(DesignSystem.Colors.deepText)
            .fixedSize(horizontal: false, vertical: true)
          Text(subtitle)
            .font(DesignSystem.Fonts.caption())
            .foregroundStyle(DesignSystem.Colors.softText)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
      .padding(16)
    }
    .frame(maxWidth: .infinity, minHeight: minHeight, maxHeight: minHeight)
    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 18, style: .continuous)
        .stroke(Color.white.opacity(0.74), lineWidth: 1)
    )
    .shadow(color: Color.black.opacity(0.04), radius: 16, x: 0, y: 8)
    .accessibilityElement(children: .combine)
  }
}

// MARK: - Extensions
extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let a: UInt64
    let r: UInt64
    let g: UInt64
    let b: UInt64
    switch hex.count {
    case 3:  // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6:  // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8:  // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (1, 1, 1, 0)
    }

    self.init(
      .sRGB,
      red: Double(r) / 255,
      green: Double(g) / 255,
      blue: Double(b) / 255,
      opacity: Double(a) / 255
    )
  }
}

struct ShadowStyle {
  var color: Color
  var radius: CGFloat
  var x: CGFloat
  var y: CGFloat

  init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
    self.color = color
    self.radius = radius
    self.x = x
    self.y = y
  }
}

// Modify View to accept ShadowStyle more easily if needed, or just use normally.
extension View {
  func designShadow(_ style: ShadowStyle) -> some View {
    self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
  }
}
