import SwiftUI

enum ResponsiveFieldMode: Equatable {
  case resting
  case active
}

/// An edge-anchored, architectural light field for Anchor's calm-state surfaces.
///
/// The aperture deliberately enters from outside the right edge instead of becoming a
/// central object. This leaves the reading field quiet while giving Home and Reset a
/// distinctive material identity. Shield never loads this view.
struct ResponsiveShelterField: View, Animatable {
  let theme: AppTheme
  let mode: ResponsiveFieldMode
  var engagement = 0.0
  var isAnimated = true
  var phaseOrigin: Date? = nil
  var elapsedOffset: TimeInterval = 0
  var frozenPhase: Double? = nil

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.scenePhase) private var scenePhase

  private var palette: ResponsiveShelterPalette {
    theme.shelterPalette
  }

  private var shouldReduceMotion: Bool {
    #if DEBUG
      if ProcessInfo.processInfo.arguments.contains("-reduceMotionReset") {
        return true
      }
    #endif
    return reduceMotion
  }

  var animatableData: Double {
    get { engagement }
    set { engagement = newValue }
  }

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [palette.backgroundTop, palette.backgroundBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )

      if isAnimated && !shouldReduceMotion && scenePhase == .active {
        TimelineView(.animation) { timeline in
          apertureArtwork(phase: normalizedPhase(at: timeline.date))
        }
      } else {
        apertureArtwork(phase: frozenPhase ?? 0.22)
      }

      LinearGradient(
        stops: [
          .init(color: Color.black.opacity(0.02), location: 0),
          .init(color: Color.clear, location: 0.46),
          .init(color: Color.black.opacity(mode == .resting ? 0.26 : 0.16), location: 1),
        ],
        startPoint: .top,
        endPoint: .bottom
      )
    }
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }

  private func normalizedPhase(at date: Date) -> Double {
    let duration = mode == .resting ? 28.0 : 8.0
    let elapsed: TimeInterval

    if let phaseOrigin {
      elapsed = max(0, date.timeIntervalSince(phaseOrigin) - elapsedOffset)
    } else {
      elapsed = date.timeIntervalSinceReferenceDate
    }

    return elapsed.truncatingRemainder(dividingBy: duration) / duration
  }

  private func apertureArtwork(phase: Double) -> some View {
    Canvas(
      opaque: false,
      colorMode: .linear,
      rendersAsynchronously: false
    ) { context, size in
      let transform = ApertureMotion(
        phase: phase,
        engagement: engagement,
        mode: mode
      )
      let drawingTransform = TidalApertureGeometry.viewportTransform(for: size)

      context.translateBy(x: drawingTransform.offsetX, y: drawingTransform.offsetY)
      context.scaleBy(x: drawingTransform.scale, y: drawingTransform.scale)

      drawTidalAperture(
        in: &context,
        phase: phase,
        motion: transform,
        style: TidalApertureStyle(theme: theme)
      )
    }
  }

  private func drawTidalAperture(
    in context: inout GraphicsContext,
    phase: Double,
    motion: ApertureMotion,
    style: TidalApertureStyle
  ) {
    drawLayer(in: &context, motion: motion, parallax: 0.34) { layer in
      drawMembrane(
        in: &layer,
        path: TidalApertureGeometry.veil,
        gradient: style.veil,
        edge: style.materialEdge,
        startPoint: CGPoint(x: 138, y: 144),
        endPoint: CGPoint(x: 434, y: 728),
        textureSeed: 1.2
      )
    }

    drawLayer(in: &context, motion: motion, parallax: 0.56) { layer in
      drawMembrane(
        in: &layer,
        path: TidalApertureGeometry.outerMembrane,
        gradient: style.outer,
        edge: style.materialEdge,
        startPoint: CGPoint(x: 146, y: 190),
        endPoint: CGPoint(x: 434, y: 700),
        textureSeed: 2.8
      )
    }

    drawLayer(in: &context, motion: motion, parallax: 0.76) { layer in
      drawMembrane(
        in: &layer,
        path: TidalApertureGeometry.middleMembrane,
        gradient: style.middle,
        edge: style.materialEdge,
        startPoint: CGPoint(x: 178, y: 220),
        endPoint: CGPoint(x: 432, y: 660),
        textureSeed: 4.4
      )
    }

    drawLayer(in: &context, motion: motion, parallax: 0.90) { layer in
      drawMembrane(
        in: &layer,
        path: TidalApertureGeometry.innerMembrane,
        gradient: style.innerGradient,
        edge: style.materialEdge,
        startPoint: CGPoint(x: 216, y: 250),
        endPoint: CGPoint(x: 432, y: 624),
        textureSeed: 6.1
      )
    }

    drawLayer(in: &context, motion: motion, parallax: 1.0) { layer in
      layer.fill(TidalApertureGeometry.apertureVoid, with: .color(style.void))
    }

    drawLayer(in: &context, motion: motion, parallax: 0.82) { layer in
      layer.drawLayer { glow in
        glow.addFilter(.blur(radius: 4.5))
        glow.stroke(
          TidalApertureGeometry.wideCaustic,
          with: .linearGradient(
            style.caustic,
            startPoint: CGPoint(x: 279, y: 201),
            endPoint: CGPoint(x: 423, y: 496)
          ),
          style: StrokeStyle(lineWidth: 5.5, lineCap: .round)
        )
      }

      layer.stroke(
        TidalApertureGeometry.fineCaustic,
        with: .color(style.fineHighlight),
        style: StrokeStyle(lineWidth: 1.25, lineCap: .round)
      )

      layer.stroke(
        TidalApertureGeometry.signalSeam,
        with: .color(style.signalSeam),
        style: StrokeStyle(lineWidth: 1.8, lineCap: .round)
      )

      layer.drawLayer { refraction in
        refraction.addFilter(.blur(radius: 5))
        refraction.stroke(
          TidalApertureGeometry.lowerRefraction,
          with: .color(style.lowerRefraction),
          style: StrokeStyle(lineWidth: 14, lineCap: .round)
        )
      }

      let glintTravel = CGFloat(sin(phase * .pi * 2)) * 2.6
      layer.translateBy(x: glintTravel * 0.2, y: glintTravel)
      layer.stroke(
        TidalApertureGeometry.glint,
        with: .color(style.glint),
        style: StrokeStyle(lineWidth: 2.4, lineCap: .round)
      )
    }
  }

  private func drawMembrane(
    in context: inout GraphicsContext,
    path: Path,
    gradient: Gradient,
    edge: Color,
    startPoint: CGPoint,
    endPoint: CGPoint,
    textureSeed: Double
  ) {
    context.drawLayer { shadow in
      shadow.addFilter(.blur(radius: 5))
      shadow.translateBy(x: 2.4, y: 5.2)
      shadow.stroke(
        path,
        with: .color(Color.black.opacity(0.18)),
        style: StrokeStyle(lineWidth: 4, lineJoin: .round)
      )
    }

    context.fill(
      path,
      with: .linearGradient(
        gradient,
        startPoint: startPoint,
        endPoint: endPoint
      )
    )
    context.stroke(
      path,
      with: .color(edge),
      style: StrokeStyle(lineWidth: 0.9, lineJoin: .round)
    )

    context.drawLayer { texture in
      texture.clip(to: path)
      drawMaterialThreads(in: &texture, seed: textureSeed)
    }
  }

  private func drawMaterialThreads(
    in context: inout GraphicsContext,
    seed: Double
  ) {
    for index in 0..<30 {
      let value = Double(index)
      let y = CGFloat(92 + value * 22 + sin(value * 1.31 + seed) * 13)
      let lift = CGFloat((unitNoise(value * 2.17 + seed) - 0.5) * 62)
      var thread = Path()
      thread.move(to: CGPoint(x: 86, y: y))
      thread.addCurve(
        to: CGPoint(x: 446, y: y + 24 + lift),
        control1: CGPoint(x: 188, y: y - 28),
        control2: CGPoint(x: 334, y: y + 44 + lift * 0.6)
      )
      context.stroke(
        thread,
        with: .color(
          index.isMultiple(of: 5)
            ? Color.black.opacity(0.075)
            : Color.white.opacity(0.24)
        ),
        style: StrokeStyle(lineWidth: index.isMultiple(of: 6) ? 0.62 : 0.36)
      )
    }

    for index in 0..<20 {
      let value = Double(index)
      let x = CGFloat(96 + value * 18 + cos(value * 1.57 + seed) * 12)
      let sway = CGFloat((unitNoise(value * 3.41 + seed) - 0.5) * 78)
      var thread = Path()
      thread.move(to: CGPoint(x: x, y: 82))
      thread.addCurve(
        to: CGPoint(x: x + 74 + sway, y: 752),
        control1: CGPoint(x: x - 38, y: 302),
        control2: CGPoint(x: x + 102 + sway * 0.6, y: 548)
      )
      context.stroke(
        thread,
        with: .color(Color.white.opacity(index.isMultiple(of: 2) ? 0.19 : 0.11)),
        style: StrokeStyle(lineWidth: 0.34)
      )
    }
  }

  private func unitNoise(_ value: Double) -> Double {
    let raw = sin(value * 12.9898) * 43_758.5453
    return raw - floor(raw)
  }

  private func drawLayer(
    in context: inout GraphicsContext,
    motion: ApertureMotion,
    parallax: CGFloat,
    content: (inout GraphicsContext) -> Void
  ) {
    context.drawLayer { layer in
      let pivot = CGPoint(x: 433, y: 362)
      let pose = motion.pose(depth: parallax)
      layer.translateBy(x: pose.x, y: pose.y)
      layer.translateBy(x: pivot.x, y: pivot.y)
      layer.rotate(by: .degrees(pose.rotation))
      layer.scaleBy(x: pose.scaleX, y: pose.scaleY)
      layer.translateBy(x: -pivot.x, y: -pivot.y)
      content(&layer)
    }
  }
}

private struct ApertureMotion {
  let phase: Double
  let focus: CGFloat
  let mode: ResponsiveFieldMode

  init(phase: Double, engagement: Double, mode: ResponsiveFieldMode) {
    self.phase = phase
    self.focus = CGFloat(min(max(engagement, 0), 1))
    self.mode = mode
  }

  func pose(depth: CGFloat) -> ApertureLayerPose {
    let clampedDepth = min(max(depth, 0), 1)
    let depthValue = Double(clampedDepth)

    switch mode {
    case .resting:
      let cycle = phase * .pi * 2
      let localCycle = cycle - (1 - depthValue) * 0.18
      let depthResponse = 0.44 + clampedDepth * 0.56
      let horizontalDrift =
        sin(localCycle) * 2.20
        + sin(localCycle * 2 + 0.72) * 0.55
      let verticalDrift =
        cos(localCycle + 0.38) * 3.60
        + cos(localCycle * 2 - 0.24) * 0.65
      let opening = CGFloat(0.5 - 0.5 * cos(localCycle))

      return ApertureLayerPose(
        x: CGFloat(horizontalDrift) * depthResponse
          - focus * (1.8 + clampedDepth * 2.2),
        y: CGFloat(verticalDrift) * (0.48 + clampedDepth * 0.52),
        scaleX: 1
          + opening * (0.004 + clampedDepth * 0.006)
          + focus * (0.005 + clampedDepth * 0.013),
        scaleY: 1
          + opening * (0.002 + clampedDepth * 0.003)
          + focus * clampedDepth * 0.004,
        rotation: (sin(localCycle + 0.25) * 0.34
          + sin(localCycle * 2 + 1.10) * 0.08) * (0.35 + depthValue * 0.65)
          - Double(focus) * depthValue * 0.08
      )

    case .active:
      let lag = (1 - depthValue) * 0.006
      let localPhase = Self.wrappedPhase(phase - lag)
      let cycle = localPhase * .pi * 2
      let breath = Self.smootherBreath(localPhase)

      return ApertureLayerPose(
        x: -breath * (4.0 + clampedDepth * 5.5),
        y: CGFloat(sin(cycle)) * (0.45 + clampedDepth * 1.55),
        scaleX: 1 + breath * (0.018 + clampedDepth * 0.042),
        scaleY: 1 + breath * (0.005 + clampedDepth * 0.012),
        rotation: sin(cycle) * 0.18 * depthValue
      )
    }
  }

  private static func wrappedPhase(_ value: Double) -> Double {
    let remainder = value.truncatingRemainder(dividingBy: 1)
    return remainder >= 0 ? remainder : remainder + 1
  }

  private static func smootherBreath(_ phase: Double) -> CGFloat {
    let triangle = phase <= 0.5 ? phase * 2 : (1 - phase) * 2
    let clamped = min(max(triangle, 0), 1)
    let eased =
      clamped * clamped * clamped
      * (clamped * (clamped * 6 - 15) + 10)
    return CGFloat(eased)
  }
}

private struct ApertureLayerPose {
  let x: CGFloat
  let y: CGFloat
  let scaleX: CGFloat
  let scaleY: CGFloat
  let rotation: Double
}

private struct TidalApertureStyle {
  let veil: Gradient
  let outer: Gradient
  let middle: Gradient
  let caustic: Gradient
  let innerGradient: Gradient
  let void: Color
  let materialEdge: Color
  let fineHighlight: Color
  let signalSeam: Color
  let lowerRefraction: Color
  let glint: Color

  init(theme: AppTheme) {
    switch theme {
    case .luminous:
      veil = Self.gradient(
        ("F7F1E8", 0.12, 0),
        ("D7C7DF", 0.34, 0.42),
        ("9ECBC8", 0.30, 0.72),
        ("1B4955", 0.08, 1)
      )
      outer = Self.gradient(
        ("FFF9EF", 0.22, 0),
        ("D8C9DF", 0.56, 0.38),
        ("91C2C1", 0.48, 0.70),
        ("1B4C58", 0.12, 1)
      )
      middle = Self.gradient(
        ("FFF9EE", 0.34, 0),
        ("E9DCEA", 0.74, 0.48),
        ("A3D0CC", 0.58, 0.78),
        ("245563", 0.14, 1)
      )
      caustic = Self.gradient(
        ("FFF9ED", 0, 0),
        ("FFF9ED", 0.90, 0.48),
        ("BDE3DB", 0.46, 0.74),
        ("BDE3DB", 0, 1)
      )
      innerGradient = Self.gradient(
        ("FFF8EC", 0.26, 0),
        ("D8C9DF", 0.62, 0.48),
        ("91C7C3", 0.48, 1)
      )
      void = Color(hex: "061B24").opacity(0.52)
      materialEdge = Color(hex: "F6F0E8").opacity(0.42)
      fineHighlight = Color(hex: "F8F0E5").opacity(0.48)
      signalSeam = Color(hex: "E8A28A").opacity(0.82)
      lowerRefraction = Color(hex: "A6CAC7").opacity(0.18)
      glint = Color(hex: "FFF9EE").opacity(0.66)

    case .grounded:
      veil = Self.gradient(
        ("F6F0E4", 0.12, 0),
        ("DCC9B9", 0.32, 0.42),
        ("9FC8BA", 0.28, 0.72),
        ("254C44", 0.08, 1)
      )
      outer = Self.gradient(
        ("FFF7E9", 0.22, 0),
        ("E2CBB7", 0.54, 0.38),
        ("9EC9B9", 0.46, 0.70),
        ("2B554A", 0.12, 1)
      )
      middle = Self.gradient(
        ("FFF8EB", 0.32, 0),
        ("EED5BE", 0.72, 0.48),
        ("ADD5C1", 0.56, 0.78),
        ("356257", 0.14, 1)
      )
      caustic = Self.gradient(
        ("FFF5E5", 0, 0),
        ("FFF5E5", 0.86, 0.48),
        ("C7E1D0", 0.42, 0.74),
        ("C7E1D0", 0, 1)
      )
      innerGradient = Self.gradient(
        ("FFF7E8", 0.26, 0),
        ("E6CDB8", 0.60, 0.48),
        ("9ECDBB", 0.46, 1)
      )
      void = Color(hex: "08241F").opacity(0.50)
      materialEdge = Color(hex: "FFF4E5").opacity(0.40)
      fineHighlight = Color(hex: "FFF3E3").opacity(0.44)
      signalSeam = Color(hex: "DF987F").opacity(0.80)
      lowerRefraction = Color(hex: "A9C7B8").opacity(0.17)
      glint = Color(hex: "FFF6E7").opacity(0.62)
    }
  }

  private static func gradient(
    _ stops: (String, Double, CGFloat)...
  ) -> Gradient {
    Gradient(
      stops: stops.map { hex, opacity, location in
        Gradient.Stop(color: Color(hex: hex).opacity(opacity), location: location)
      }
    )
  }
}

private enum TidalApertureGeometry {
  static let designSize = CGSize(width: 390, height: 844)

  static func viewportTransform(
    for size: CGSize
  ) -> (scale: CGFloat, offsetX: CGFloat, offsetY: CGFloat) {
    let scale = max(size.width / designSize.width, size.height / designSize.height)
    return (
      scale,
      size.width - designSize.width * scale,
      (size.height - designSize.height * scale) / 2
    )
  }

  static let veil: Path = {
    var path = Path()
    path.move(to: CGPoint(x: 432, y: 82))
    path.addCurve(
      to: CGPoint(x: 302, y: 210),
      control1: CGPoint(x: 364, y: 104),
      control2: CGPoint(x: 328, y: 154)
    )
    path.addCurve(
      to: CGPoint(x: 112, y: 430),
      control1: CGPoint(x: 254, y: 292),
      control2: CGPoint(x: 170, y: 392)
    )
    path.addCurve(
      to: CGPoint(x: 226, y: 570),
      control1: CGPoint(x: 138, y: 482),
      control2: CGPoint(x: 176, y: 540)
    )
    path.addCurve(
      to: CGPoint(x: 432, y: 728),
      control1: CGPoint(x: 300, y: 620),
      control2: CGPoint(x: 374, y: 690)
    )
    path.closeSubpath()
    return path
  }()

  static let outerMembrane: Path = {
    var path = Path()
    path.move(to: CGPoint(x: 432, y: 130))
    path.addCurve(
      to: CGPoint(x: 286, y: 250),
      control1: CGPoint(x: 354, y: 154),
      control2: CGPoint(x: 320, y: 204)
    )
    path.addCurve(
      to: CGPoint(x: 136, y: 426),
      control1: CGPoint(x: 248, y: 318),
      control2: CGPoint(x: 180, y: 400)
    )
    path.addCurve(
      to: CGPoint(x: 268, y: 560),
      control1: CGPoint(x: 174, y: 472),
      control2: CGPoint(x: 218, y: 526)
    )
    path.addCurve(
      to: CGPoint(x: 432, y: 694),
      control1: CGPoint(x: 324, y: 600),
      control2: CGPoint(x: 382, y: 660)
    )
    path.closeSubpath()
    return path
  }()

  static let middleMembrane: Path = {
    var path = Path()
    path.move(to: CGPoint(x: 432, y: 178))
    path.addCurve(
      to: CGPoint(x: 310, y: 282),
      control1: CGPoint(x: 366, y: 198),
      control2: CGPoint(x: 336, y: 238)
    )
    path.addCurve(
      to: CGPoint(x: 170, y: 456),
      control1: CGPoint(x: 270, y: 344),
      control2: CGPoint(x: 210, y: 426)
    )
    path.addCurve(
      to: CGPoint(x: 300, y: 570),
      control1: CGPoint(x: 212, y: 490),
      control2: CGPoint(x: 254, y: 534)
    )
    path.addCurve(
      to: CGPoint(x: 432, y: 652),
      control1: CGPoint(x: 350, y: 596),
      control2: CGPoint(x: 394, y: 630)
    )
    path.closeSubpath()
    return path
  }()

  static let innerMembrane: Path = {
    var path = Path()
    path.move(to: CGPoint(x: 432, y: 238))
    path.addCurve(
      to: CGPoint(x: 330, y: 318),
      control1: CGPoint(x: 374, y: 254),
      control2: CGPoint(x: 350, y: 286)
    )
    path.addCurve(
      to: CGPoint(x: 220, y: 474),
      control1: CGPoint(x: 300, y: 366),
      control2: CGPoint(x: 252, y: 440)
    )
    path.addCurve(
      to: CGPoint(x: 316, y: 546),
      control1: CGPoint(x: 252, y: 500),
      control2: CGPoint(x: 280, y: 528)
    )
    path.addCurve(
      to: CGPoint(x: 432, y: 610),
      control1: CGPoint(x: 356, y: 562),
      control2: CGPoint(x: 396, y: 590)
    )
    path.closeSubpath()
    return path
  }()

  static let apertureVoid: Path = {
    var path = Path()
    path.move(to: CGPoint(x: 433, y: 278))
    path.addCurve(
      to: CGPoint(x: 350, y: 348),
      control1: CGPoint(x: 386, y: 292),
      control2: CGPoint(x: 366, y: 320)
    )
    path.addCurve(
      to: CGPoint(x: 278, y: 470),
      control1: CGPoint(x: 330, y: 384),
      control2: CGPoint(x: 298, y: 438)
    )
    path.addCurve(
      to: CGPoint(x: 340, y: 528),
      control1: CGPoint(x: 298, y: 492),
      control2: CGPoint(x: 316, y: 514)
    )
    path.addCurve(
      to: CGPoint(x: 433, y: 572),
      control1: CGPoint(x: 372, y: 538),
      control2: CGPoint(x: 402, y: 558)
    )
    path.closeSubpath()
    return path
  }()

  static let wideCaustic: Path = {
    var path = Path()
    path.move(to: CGPoint(x: 190, y: 420))
    path.addCurve(
      to: CGPoint(x: 300, y: 476),
      control1: CGPoint(x: 232, y: 424),
      control2: CGPoint(x: 270, y: 448)
    )
    path.addCurve(
      to: CGPoint(x: 424, y: 632),
      control1: CGPoint(x: 350, y: 520),
      control2: CGPoint(x: 390, y: 586)
    )
    return path
  }()

  static let fineCaustic: Path = {
    var path = Path()
    path.move(to: CGPoint(x: 282, y: 246))
    path.addCurve(
      to: CGPoint(x: 286, y: 430),
      control1: CGPoint(x: 300, y: 304),
      control2: CGPoint(x: 298, y: 370)
    )
    path.addCurve(
      to: CGPoint(x: 414, y: 648),
      control1: CGPoint(x: 310, y: 508),
      control2: CGPoint(x: 366, y: 594)
    )
    return path
  }()

  static let signalSeam: Path = {
    var path = Path()
    path.move(to: CGPoint(x: 176, y: 456))
    path.addCurve(
      to: CGPoint(x: 304, y: 566),
      control1: CGPoint(x: 224, y: 484),
      control2: CGPoint(x: 268, y: 530)
    )
    return path
  }()

  static let lowerRefraction: Path = {
    var path = Path()
    path.move(to: CGPoint(x: 226, y: 570))
    path.addCurve(
      to: CGPoint(x: 416, y: 708),
      control1: CGPoint(x: 294, y: 610),
      control2: CGPoint(x: 358, y: 674)
    )
    return path
  }()

  static let glint: Path = {
    var path = Path()
    path.move(to: CGPoint(x: 326, y: 318))
    path.addCurve(
      to: CGPoint(x: 296, y: 430),
      control1: CGPoint(x: 312, y: 354),
      control2: CGPoint(x: 300, y: 394)
    )
    path.addCurve(
      to: CGPoint(x: 344, y: 532),
      control1: CGPoint(x: 306, y: 470),
      control2: CGPoint(x: 324, y: 504)
    )
    return path
  }()
}

#Preview("Grounded Home") {
  ResponsiveShelterField(theme: .grounded, mode: .resting, isAnimated: false)
    .ignoresSafeArea()
}

#Preview("Luminous Reset") {
  ResponsiveShelterField(theme: .luminous, mode: .active, isAnimated: false)
    .ignoresSafeArea()
}
