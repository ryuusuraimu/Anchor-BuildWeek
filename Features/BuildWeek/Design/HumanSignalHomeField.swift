import SwiftUI

/// Anchor's calm-state signature surface.
///
/// The layered membrane suggests a prepared human signal without becoming a logo,
/// spinner, or medical illustration. It is intentionally decorative, never interactive,
/// and never loaded by Shield.
struct HumanSignalHomeField: View, Animatable {
  var engagement = 0.0

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.scenePhase) private var scenePhase

  var animatableData: Double {
    get { engagement }
    set { engagement = newValue }
  }

  private var shouldReduceMotion: Bool {
    #if DEBUG
      if ProcessInfo.processInfo.arguments.contains("-reduceMotionHome") {
        return true
      }
    #endif
    return reduceMotion
  }

  var body: some View {
    ZStack {
      BuildWeekDesign.HumanSignal.background

      LinearGradient(
        stops: [
          .init(color: BuildWeekDesign.HumanSignal.backgroundWarm.opacity(0.92), location: 0),
          .init(color: BuildWeekDesign.HumanSignal.background.opacity(0.18), location: 0.52),
          .init(color: Color(hex: "EAE5DC").opacity(0.46), location: 1),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )

      if !shouldReduceMotion && scenePhase == .active {
        TimelineView(.animation) { timeline in
          artwork(phase: normalizedPhase(at: timeline.date))
        }
      } else {
        artwork(phase: 0.18)
      }

      LinearGradient(
        stops: [
          .init(color: Color.white.opacity(0.16), location: 0),
          .init(color: Color.clear, location: 0.34),
          .init(color: Color(hex: "BDB5AA").opacity(0.08), location: 1),
        ],
        startPoint: .top,
        endPoint: .bottom
      )
    }
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }

  private func normalizedPhase(at date: Date) -> Double {
    date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 32) / 32
  }

  private func artwork(phase: Double) -> some View {
    Canvas(
      opaque: false,
      colorMode: .linear,
      rendersAsynchronously: false
    ) { context, size in
      let viewport = HumanSignalGeometry.viewportTransform(for: size)
      context.translateBy(x: viewport.offsetX, y: viewport.offsetY)
      context.scaleBy(x: viewport.scale, y: viewport.scale)

      drawAmbientGrain(in: &context)

      drawMembrane(
        in: &context,
        path: HumanSignalGeometry.outerVeil,
        gradient: HumanSignalMaterial.outerVeil,
        startPoint: CGPoint(x: 118, y: 170),
        endPoint: CGPoint(x: 412, y: 706),
        phase: phase,
        depth: 0.18,
        opacity: 0.84,
        textureSeed: 0.9
      )

      drawMembrane(
        in: &context,
        path: HumanSignalGeometry.seaGlassSweep,
        gradient: HumanSignalMaterial.seaGlass,
        startPoint: CGPoint(x: 130, y: 308),
        endPoint: CGPoint(x: 406, y: 724),
        phase: phase,
        depth: 0.38,
        opacity: 0.92,
        textureSeed: 2.4
      )

      drawMembrane(
        in: &context,
        path: HumanSignalGeometry.lilacFold,
        gradient: HumanSignalMaterial.lilac,
        startPoint: CGPoint(x: 174, y: 252),
        endPoint: CGPoint(x: 410, y: 700),
        phase: phase,
        depth: 0.56,
        opacity: 0.94,
        textureSeed: 4.1
      )

      drawMembrane(
        in: &context,
        path: HumanSignalGeometry.opalineFold,
        gradient: HumanSignalMaterial.opaline,
        startPoint: CGPoint(x: 168, y: 184),
        endPoint: CGPoint(x: 412, y: 636),
        phase: phase,
        depth: 0.74,
        opacity: 0.78,
        textureSeed: 5.8
      )

      drawMembrane(
        in: &context,
        path: HumanSignalGeometry.innerRibbon,
        gradient: HumanSignalMaterial.innerRibbon,
        startPoint: CGPoint(x: 220, y: 296),
        endPoint: CGPoint(x: 412, y: 674),
        phase: phase,
        depth: 0.92,
        opacity: 0.88,
        textureSeed: 7.3
      )

      drawCaustics(in: &context, phase: phase)
    }
  }

  private func drawAmbientGrain(in context: inout GraphicsContext) {
    for index in 0..<96 {
      let value = Double(index)
      let x = CGFloat(10 + unitNoise(value * 1.71 + 0.4) * 370)
      let y = CGFloat(24 + unitNoise(value * 2.63 + 2.1) * 796)
      let length = CGFloat(0.5 + unitNoise(value * 3.19 + 4.7) * 1.8)
      let isLight = index.isMultiple(of: 3)

      var fleck = Path()
      fleck.move(to: CGPoint(x: x, y: y))
      fleck.addLine(to: CGPoint(x: x + length, y: y + length * 0.28))
      context.stroke(
        fleck,
        with: .color(
          isLight
            ? Color.white.opacity(0.18)
            : BuildWeekDesign.HumanSignal.ink.opacity(0.018)
        ),
        style: StrokeStyle(lineWidth: isLight ? 0.42 : 0.28, lineCap: .round)
      )
    }
  }

  private func drawMembrane(
    in context: inout GraphicsContext,
    path: Path,
    gradient: Gradient,
    startPoint: CGPoint,
    endPoint: CGPoint,
    phase: Double,
    depth: CGFloat,
    opacity: Double,
    textureSeed: Double
  ) {
    context.drawLayer { layer in
      applyPose(to: &layer, phase: phase, depth: depth)
      layer.opacity = opacity

      layer.drawLayer { shadow in
        shadow.addFilter(.blur(radius: 3.2 + depth * 2.4))
        shadow.translateBy(x: 1.4 + depth * 2.2, y: 3.2 + depth * 4.6)
        shadow.stroke(
          path,
          with: .color(BuildWeekDesign.HumanSignal.ink.opacity(0.10 + Double(depth) * 0.035)),
          style: StrokeStyle(lineWidth: 2.2 + depth * 2.8, lineJoin: .round)
        )
      }

      layer.fill(
        path,
        with: .linearGradient(
          gradient,
          startPoint: startPoint,
          endPoint: endPoint
        )
      )

      layer.fill(
        path,
        with: .linearGradient(
          HumanSignalMaterial.specular,
          startPoint: CGPoint(x: startPoint.x + 34, y: startPoint.y - 54),
          endPoint: CGPoint(x: endPoint.x - 22, y: endPoint.y + 30)
        )
      )

      layer.stroke(
        path,
        with: .linearGradient(
          HumanSignalMaterial.edge,
          startPoint: startPoint,
          endPoint: endPoint
        ),
        style: StrokeStyle(lineWidth: 1.18, lineJoin: .round)
      )

      layer.drawLayer { texture in
        texture.clip(to: path)
        drawFibers(
          in: &texture,
          depth: depth,
          seed: textureSeed
        )
      }
    }
  }

  private func applyPose(
    to context: inout GraphicsContext,
    phase: Double,
    depth: CGFloat
  ) {
    let cycle = phase * .pi * 2
    let depthValue = Double(depth)
    let focus = CGFloat(min(max(engagement, 0), 1))
    let pivot = CGPoint(x: 356, y: 410)
    let x =
      CGFloat(sin(cycle + depthValue * 0.74)) * (0.7 + depth * 1.7)
      - focus * (0.8 + depth * 1.8)
    let y = CGFloat(cos(cycle + depthValue * 0.48)) * (1.1 + depth * 2.1)
    let rotation =
      sin(cycle + depthValue) * (0.08 + depthValue * 0.18)
      - Double(focus) * depthValue * 0.08
    let expansion = 1 + focus * (0.002 + depth * 0.006)

    context.translateBy(x: x, y: y)
    context.translateBy(x: pivot.x, y: pivot.y)
    context.rotate(by: .degrees(rotation))
    context.scaleBy(x: expansion, y: expansion)
    context.translateBy(x: -pivot.x, y: -pivot.y)
  }

  private func drawFibers(
    in context: inout GraphicsContext,
    depth: CGFloat,
    seed: Double
  ) {
    let primary = Color.white.opacity(0.28 + Double(depth) * 0.08)
    let secondary = BuildWeekDesign.HumanSignal.ink.opacity(0.072)

    for index in 0..<24 {
      let value = Double(index)
      let y = CGFloat(104 + value * 27 + sin(value * 1.7 + seed) * 13)
      let rise = CGFloat((unitNoise(value * 1.31 + seed) - 0.5) * 56)
      var fiber = Path()
      fiber.move(to: CGPoint(x: 78, y: y))
      fiber.addCurve(
        to: CGPoint(x: 438, y: y + 20 + rise),
        control1: CGPoint(x: 172, y: y - 22 - rise * 0.18),
        control2: CGPoint(x: 324, y: y + 38 + rise * 0.54)
      )
      context.stroke(
        fiber,
        with: .color(index.isMultiple(of: 4) ? secondary : primary),
        style: StrokeStyle(lineWidth: index.isMultiple(of: 5) ? 0.72 : 0.40)
      )
    }

    for index in 0..<18 {
      let value = Double(index)
      let x = CGFloat(92 + value * 21 + cos(value * 1.3 + seed) * 11)
      let sway = CGFloat((unitNoise(value * 2.17 + seed) - 0.5) * 72)
      var fiber = Path()
      fiber.move(to: CGPoint(x: x, y: 92))
      fiber.addCurve(
        to: CGPoint(x: x + 58 + sway, y: 762),
        control1: CGPoint(x: x - 42 - sway * 0.3, y: 304),
        control2: CGPoint(x: x + 104 + sway * 0.6, y: 552)
      )
      context.stroke(
        fiber,
        with: .color(primary.opacity(index.isMultiple(of: 2) ? 0.88 : 0.66)),
        style: StrokeStyle(lineWidth: index.isMultiple(of: 6) ? 0.56 : 0.34)
      )
    }

    for index in 0..<38 {
      let value = Double(index)
      let x = CGFloat(78 + unitNoise(value * 3.37 + seed) * 350)
      let y = CGFloat(96 + unitNoise(value * 4.91 + seed) * 650)
      let run = CGFloat(20 + unitNoise(value * 2.23 + seed) * 54)
      let lift = CGFloat((unitNoise(value * 5.13 + seed) - 0.5) * 38)
      var wisp = Path()
      wisp.move(to: CGPoint(x: x, y: y))
      wisp.addCurve(
        to: CGPoint(x: x + run, y: y + lift),
        control1: CGPoint(x: x + run * 0.32, y: y - lift * 0.22),
        control2: CGPoint(x: x + run * 0.72, y: y + lift * 0.76)
      )
      context.stroke(
        wisp,
        with: .color(
          index.isMultiple(of: 5)
            ? secondary.opacity(0.92)
            : primary.opacity(0.78)
        ),
        style: StrokeStyle(lineWidth: 0.30, lineCap: .round)
      )
    }
  }

  private func unitNoise(_ value: Double) -> Double {
    let raw = sin(value * 12.9898) * 43_758.5453
    return raw - floor(raw)
  }

  private func drawCaustics(
    in context: inout GraphicsContext,
    phase: Double
  ) {
    let travel = CGFloat(sin(phase * .pi * 2)) * 1.4

    context.drawLayer { layer in
      layer.translateBy(x: travel * 0.3, y: travel)
      layer.drawLayer { glow in
        glow.addFilter(.blur(radius: 5.5))
        glow.stroke(
          HumanSignalGeometry.wideCaustic,
          with: .linearGradient(
            HumanSignalMaterial.caustic,
            startPoint: CGPoint(x: 176, y: 244),
            endPoint: CGPoint(x: 398, y: 636)
          ),
          style: StrokeStyle(lineWidth: 7, lineCap: .round)
        )
      }

      layer.stroke(
        HumanSignalGeometry.fineCaustic,
        with: .linearGradient(
          HumanSignalMaterial.fineLight,
          startPoint: CGPoint(x: 256, y: 240),
          endPoint: CGPoint(x: 398, y: 628)
        ),
        style: StrokeStyle(lineWidth: 1.26, lineCap: .round)
      )

      layer.stroke(
        HumanSignalGeometry.lilacSeam,
        with: .color(BuildWeekDesign.HumanSignal.lilac.opacity(0.46)),
        style: StrokeStyle(lineWidth: 1.15, lineCap: .round)
      )

      layer.stroke(
        HumanSignalGeometry.innerContour,
        with: .linearGradient(
          HumanSignalMaterial.contour,
          startPoint: CGPoint(x: 206, y: 320),
          endPoint: CGPoint(x: 406, y: 696)
        ),
        style: StrokeStyle(lineWidth: 0.72, lineCap: .round)
      )
    }
  }
}

private enum HumanSignalMaterial {
  static let outerVeil = Gradient(
    stops: [
      .init(color: Color(hex: "FFFDF7").opacity(0.76), location: 0),
      .init(color: Color(hex: "DDD1DF").opacity(0.64), location: 0.40),
      .init(color: Color(hex: "A8CCC7").opacity(0.52), location: 0.78),
      .init(color: Color(hex: "6C9592").opacity(0.20), location: 1),
    ]
  )

  static let seaGlass = Gradient(
    stops: [
      .init(color: Color(hex: "E9F0E9").opacity(0.55), location: 0),
      .init(color: Color(hex: "A9CEC6").opacity(0.94), location: 0.48),
      .init(color: Color(hex: "628F8C").opacity(0.86), location: 0.82),
      .init(color: Color(hex: "254F52").opacity(0.58), location: 1),
    ]
  )

  static let lilac = Gradient(
    stops: [
      .init(color: Color(hex: "F5EDF1").opacity(0.72), location: 0),
      .init(color: Color(hex: "D3C2D6").opacity(0.98), location: 0.46),
      .init(color: Color(hex: "A893B2").opacity(0.86), location: 0.76),
      .init(color: Color(hex: "667D82").opacity(0.46), location: 1),
    ]
  )

  static let opaline = Gradient(
    stops: [
      .init(color: Color(hex: "FFFDF5").opacity(0.90), location: 0),
      .init(color: Color(hex: "ECE3E7").opacity(0.82), location: 0.38),
      .init(color: Color(hex: "C6DDD6").opacity(0.70), location: 0.72),
      .init(color: Color(hex: "7AA39F").opacity(0.28), location: 1),
    ]
  )

  static let innerRibbon = Gradient(
    stops: [
      .init(color: Color(hex: "FDF8EE").opacity(0.84), location: 0),
      .init(color: Color(hex: "C7DCD6").opacity(0.94), location: 0.52),
      .init(color: Color(hex: "729C98").opacity(0.74), location: 0.78),
      .init(color: Color(hex: "375F61").opacity(0.48), location: 1),
    ]
  )

  static let edge = Gradient(
    stops: [
      .init(color: Color.white.opacity(0.82), location: 0),
      .init(color: Color(hex: "E9E0E3").opacity(0.34), location: 0.54),
      .init(color: Color(hex: "6E9895").opacity(0.22), location: 1),
    ]
  )

  static let specular = Gradient(
    stops: [
      .init(color: Color.white.opacity(0), location: 0),
      .init(color: Color.white.opacity(0.12), location: 0.26),
      .init(color: Color.white.opacity(0.34), location: 0.46),
      .init(color: Color.white.opacity(0.04), location: 0.64),
      .init(color: Color(hex: "315D5E").opacity(0.06), location: 1),
    ]
  )

  static let caustic = Gradient(
    stops: [
      .init(color: Color.white.opacity(0), location: 0),
      .init(color: Color.white.opacity(0.66), location: 0.44),
      .init(color: Color(hex: "D6ECE5").opacity(0.44), location: 0.72),
      .init(color: Color.white.opacity(0), location: 1),
    ]
  )

  static let fineLight = Gradient(
    stops: [
      .init(color: Color.white.opacity(0.10), location: 0),
      .init(color: Color.white.opacity(0.70), location: 0.42),
      .init(color: Color(hex: "E5F0EA").opacity(0.42), location: 0.76),
      .init(color: Color.white.opacity(0.08), location: 1),
    ]
  )

  static let contour = Gradient(
    stops: [
      .init(color: Color.white.opacity(0.08), location: 0),
      .init(color: Color(hex: "D9C8DE").opacity(0.42), location: 0.48),
      .init(color: Color(hex: "426F70").opacity(0.24), location: 1),
    ]
  )
}

private enum HumanSignalGeometry {
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

  static let outerVeil: Path = {
    var path = Path()
    path.move(to: CGPoint(x: 414, y: 82))
    path.addCurve(
      to: CGPoint(x: 286, y: 222),
      control1: CGPoint(x: 350, y: 98),
      control2: CGPoint(x: 306, y: 154)
    )
    path.addCurve(
      to: CGPoint(x: 116, y: 358),
      control1: CGPoint(x: 260, y: 286),
      control2: CGPoint(x: 194, y: 326)
    )
    path.addCurve(
      to: CGPoint(x: 276, y: 486),
      control1: CGPoint(x: 176, y: 385),
      control2: CGPoint(x: 239, y: 422)
    )
    path.addCurve(
      to: CGPoint(x: 414, y: 726),
      control1: CGPoint(x: 329, y: 568),
      control2: CGPoint(x: 371, y: 664)
    )
    path.closeSubpath()
    return path
  }()

  static let seaGlassSweep: Path = {
    var path = Path()
    path.move(to: CGPoint(x: 414, y: 188))
    path.addCurve(
      to: CGPoint(x: 252, y: 308),
      control1: CGPoint(x: 342, y: 204),
      control2: CGPoint(x: 304, y: 266)
    )
    path.addCurve(
      to: CGPoint(x: 116, y: 358),
      control1: CGPoint(x: 210, y: 340),
      control2: CGPoint(x: 164, y: 350)
    )
    path.addCurve(
      to: CGPoint(x: 284, y: 510),
      control1: CGPoint(x: 190, y: 396),
      control2: CGPoint(x: 250, y: 438)
    )
    path.addCurve(
      to: CGPoint(x: 414, y: 748),
      control1: CGPoint(x: 327, y: 602),
      control2: CGPoint(x: 371, y: 690)
    )
    path.closeSubpath()
    return path
  }()

  static let lilacFold: Path = {
    var path = Path()
    path.move(to: CGPoint(x: 414, y: 138))
    path.addCurve(
      to: CGPoint(x: 264, y: 288),
      control1: CGPoint(x: 343, y: 154),
      control2: CGPoint(x: 302, y: 218)
    )
    path.addCurve(
      to: CGPoint(x: 170, y: 376),
      control1: CGPoint(x: 238, y: 333),
      control2: CGPoint(x: 209, y: 361)
    )
    path.addCurve(
      to: CGPoint(x: 304, y: 516),
      control1: CGPoint(x: 224, y: 411),
      control2: CGPoint(x: 270, y: 449)
    )
    path.addCurve(
      to: CGPoint(x: 414, y: 728),
      control1: CGPoint(x: 338, y: 584),
      control2: CGPoint(x: 376, y: 669)
    )
    path.closeSubpath()
    return path
  }()

  static let opalineFold: Path = {
    var path = Path()
    path.move(to: CGPoint(x: 414, y: 104))
    path.addCurve(
      to: CGPoint(x: 279, y: 242),
      control1: CGPoint(x: 349, y: 119),
      control2: CGPoint(x: 304, y: 173)
    )
    path.addCurve(
      to: CGPoint(x: 156, y: 338),
      control1: CGPoint(x: 253, y: 298),
      control2: CGPoint(x: 207, y: 327)
    )
    path.addCurve(
      to: CGPoint(x: 270, y: 382),
      control1: CGPoint(x: 202, y: 342),
      control2: CGPoint(x: 241, y: 354)
    )
    path.addCurve(
      to: CGPoint(x: 414, y: 664),
      control1: CGPoint(x: 331, y: 445),
      control2: CGPoint(x: 366, y: 578)
    )
    path.closeSubpath()
    return path
  }()

  static let innerRibbon: Path = {
    var path = Path()
    path.move(to: CGPoint(x: 414, y: 214))
    path.addCurve(
      to: CGPoint(x: 285, y: 338),
      control1: CGPoint(x: 356, y: 230),
      control2: CGPoint(x: 321, y: 286)
    )
    path.addCurve(
      to: CGPoint(x: 216, y: 408),
      control1: CGPoint(x: 260, y: 374),
      control2: CGPoint(x: 238, y: 396)
    )
    path.addCurve(
      to: CGPoint(x: 326, y: 532),
      control1: CGPoint(x: 266, y: 433),
      control2: CGPoint(x: 300, y: 471)
    )
    path.addCurve(
      to: CGPoint(x: 414, y: 692),
      control1: CGPoint(x: 352, y: 592),
      control2: CGPoint(x: 382, y: 651)
    )
    path.closeSubpath()
    return path
  }()

  static let wideCaustic: Path = {
    var path = Path()
    path.move(to: CGPoint(x: 178, y: 330))
    path.addCurve(
      to: CGPoint(x: 300, y: 416),
      control1: CGPoint(x: 230, y: 344),
      control2: CGPoint(x: 270, y: 375)
    )
    path.addCurve(
      to: CGPoint(x: 400, y: 642),
      control1: CGPoint(x: 346, y: 483),
      control2: CGPoint(x: 365, y: 576)
    )
    return path
  }()

  static let fineCaustic: Path = {
    var path = Path()
    path.move(to: CGPoint(x: 264, y: 246))
    path.addCurve(
      to: CGPoint(x: 304, y: 409),
      control1: CGPoint(x: 286, y: 302),
      control2: CGPoint(x: 302, y: 354)
    )
    path.addCurve(
      to: CGPoint(x: 394, y: 620),
      control1: CGPoint(x: 326, y: 486),
      control2: CGPoint(x: 359, y: 559)
    )
    return path
  }()

  static let lilacSeam: Path = {
    var path = Path()
    path.move(to: CGPoint(x: 170, y: 376))
    path.addCurve(
      to: CGPoint(x: 300, y: 496),
      control1: CGPoint(x: 230, y: 407),
      control2: CGPoint(x: 274, y: 443)
    )
    return path
  }()

  static let innerContour: Path = {
    var path = Path()
    path.move(to: CGPoint(x: 205, y: 388))
    path.addCurve(
      to: CGPoint(x: 312, y: 515),
      control1: CGPoint(x: 248, y: 411),
      control2: CGPoint(x: 286, y: 456)
    )
    path.addCurve(
      to: CGPoint(x: 405, y: 694),
      control1: CGPoint(x: 346, y: 580),
      control2: CGPoint(x: 374, y: 648)
    )
    return path
  }()
}

#Preview("Human Signal") {
  HumanSignalHomeField()
    .ignoresSafeArea()
}
