import SwiftUI

// MARK:   HEARTBEAT ENGINE — The Metronome

/// Drives the entire scene. Everything syncs to this pulse.
@Observable @MainActor
final class HeartbeatEngine {
  // MARK: - Public state (read by views)
  private(set) var beatCount: Int = 0
  private(set) var phase: Phase = .calm
  private(set) var bpm: Double = 72
  private(set) var elapsed: Double = 0
  private(set) var intensity: Double = 0  // 0…1, drives all visual params
  private(set) var isFinished = false

  // Beat "flash" — true for a brief instant on each beat
  private(set) var beatFlash = false

  enum Phase: Equatable {
    case calm  // 0-2s:   subtle unease
    case rising  // 2-4s:   things go wrong
    case climax  // 4-5.5s: unbearable
    case cut  // 5.5s+:  hard snap to black
  }

  // MARK: - Timing config
  private let calmEnd: Double = 2.0
  private let risingEnd: Double = 4.0
  private let climaxEnd: Double = 5.5
  private let totalDuration: Double = 5.5

  private let bpmStart: Double = 72
  private let bpmEnd: Double = 190

  // MARK: - Internal
  private var lastBeatTime: Double = 0
  private var startTime: Date?
  private var displayLink: CADisplayLink?

  // MARK: - Start / Stop

  func start() {
    guard startTime == nil else { return }
    startTime = Date()
    elapsed = 0
    beatCount = 0
    phase = .calm
    intensity = 0
    isFinished = false
    lastBeatTime = 0

    let link = CADisplayLink(target: self, selector: #selector(tick))
    link.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120, preferred: 120)
    link.add(to: .main, forMode: .common)
    displayLink = link
  }

  func stop() {
    displayLink?.invalidate()
    displayLink = nil
  }

  // MARK: - Frame tick

  @objc private func tick(_ link: CADisplayLink) {
    guard let startTime else { return }
    elapsed = Date().timeIntervalSince(startTime)

    // Phase transitions
    if elapsed >= climaxEnd {
      if phase != .cut {
        phase = .cut
        isFinished = true
        stop()
      }
      return
    } else if elapsed >= risingEnd {
      phase = .climax
    } else if elapsed >= calmEnd {
      phase = .rising
    } else {
      phase = .calm
    }

    // Intensity: 0 → 1 over the duration
    intensity = min(elapsed / totalDuration, 1.0)

    // BPM acceleration (exponential curve for more urgency at the end)
    let t = intensity
    bpm = bpmStart + (bpmEnd - bpmStart) * (t * t)  // quadratic ramp

    // Beat detection
    let beatInterval = 60.0 / bpm
    if elapsed - lastBeatTime >= beatInterval {
      lastBeatTime = elapsed
      beatCount += 1
      beatFlash = true
      // Reset flash after a brief moment
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) { [weak self] in
        self?.beatFlash = false
      }
    }
  }
}

// MARK: - ═══════════════════════════════════════════════════
// MARK:   PANIC INTRO VIEW — The POV Shot
// MARK: - ═══════════════════════════════════════════════════

struct PanicIntroView: View {
  let onComplete: () -> Void

  @State private var engine = HeartbeatEngine()
  @State private var hasCut = false

  var body: some View {
    ZStack {
      if hasCut {
        // Hard cut to black — silence
        Color.black
          .ignoresSafeArea()
      } else {
        // The chaos
        chaosLayer
      }
    }
    .onAppear {
      engine.start()
    }
    .onDisappear {
      engine.stop()
    }
    .onChange(of: engine.isFinished) { _, finished in
      if finished {
        // HARD CUT — no animation, instant snap
        hasCut = true
        // Brief silence, then advance
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
          onComplete()
        }
      }
    }
  }

  // MARK: - Chaos Layer

  private var chaosLayer: some View {
    let i = engine.intensity
    let beating = engine.beatFlash

    return ZStack {
      // Base white that dims toward gray
      Color(white: 1.0 - i * 0.15)
        .ignoresSafeArea()

      // Chromatic aberration layers (RGB split)
      chromaticAberration(intensity: i, beating: beating)

      // Vignette / tunnel vision
      RadialGradient(
        colors: [
          Color.clear,
          Color.black.opacity(Double(i) * 0.6),
        ],
        center: .center,
        startRadius: 100,
        endRadius: 350
      )
      .ignoresSafeArea()
      .allowsHitTesting(false)

      // Beat flash overlay (white strobe)
      if beating && engine.phase == .climax {
        Color.white.opacity(0.15)
          .ignoresSafeArea()
          .allowsHitTesting(false)
      }
    }
    // Breathing scale — zoom on every beat
    .scaleEffect(beating ? 1.0 + CGFloat(i) * 0.06 : 1.0)
    .animation(.easeOut(duration: 0.08), value: beating)
    // Liquid blur — loses focus as intensity rises
    .blur(radius: beating ? CGFloat(i) * 4.0 : CGFloat(i) * 1.5)
    .animation(.easeOut(duration: 0.1), value: beating)
    // Haptics
    .sensoryFeedback(
      .impact(weight: .heavy, intensity: min(i + 0.3, 1.0)), trigger: engine.beatCount)
  }

  // MARK: - Chromatic Aberration + Glitch Text

  /// Three layers of text offset in R/G/B channels
  private func chromaticAberration(intensity i: Double, beating: Bool) -> some View {
    let shift = beating ? CGFloat(i) * 8.0 : CGFloat(i) * 2.0

    return ZStack {
      // RED channel
      glitchTextLayer(intensity: i, beating: beating)
        .foregroundStyle(Color.red)
        .opacity(i > 0.3 ? 0.35 : 0)
        .offset(x: -shift, y: shift * 0.5)
        .blendMode(.screen)

      // BLUE channel
      glitchTextLayer(intensity: i, beating: beating)
        .foregroundStyle(Color.blue)
        .opacity(i > 0.3 ? 0.3 : 0)
        .offset(x: shift, y: -shift * 0.3)
        .blendMode(.screen)

      // MAIN (dark) layer
      glitchTextLayer(intensity: i, beating: beating)
        .foregroundStyle(Color(hex: "1A1A2E").opacity(0.7 + i * 0.3))
    }
  }

  // MARK: - Glitch Text Layer

  private func glitchTextLayer(intensity i: Double, beating: Bool) -> some View {
    let words = [
      "Late", "Ticket", "People", "Don't stare",
      "Hurry", "Phone", "Too many", "Watch out",
      "Excuse me", "Move", "Sorry", "Wait",
      "Why won't you move", "Stop", "Keys", "Time",
      "Can't breathe", "Too loud", "Help", "Run",
    ]

    return GeometryReader { proxy in
      ForEach(0..<min(8 + Int(i * 12), words.count), id: \.self) { idx in
        GlitchWord(
          text: words[idx],
          index: idx,
          size: proxy.size,
          intensity: i,
          beatFlash: beating,
          beatCount: engine.beatCount
        )
      }
    }
  }
}

// MARK:   GLITCH WORD — Individual Attacking Text

/// Each word is an independent attacker that jitters synced to the beat.
private struct GlitchWord: View {
  let text: String
  let index: Int
  let size: CGSize
  let intensity: Double
  let beatFlash: Bool
  let beatCount: Int

  // Deterministic base position using golden ratio scatter
  private var baseX: CGFloat {
    let g = 0.618033988749895
    let x = (Double(index) * g * 1.7).truncatingRemainder(dividingBy: 1.0)
    return 30 + CGFloat(x) * (size.width - 60)
  }
  private var baseY: CGFloat {
    let g = 0.381966011250105
    let y = (Double(index) * g * 2.3).truncatingRemainder(dividingBy: 1.0)
    return 60 + CGFloat(y) * (size.height - 120)
  }

  // Per-word properties derived from index
  private var fontSize: CGFloat {
    let base: CGFloat = CGFloat(16 + (index * 7) % 14)  // 16-29
    return base + CGFloat(intensity) * CGFloat((index * 3) % 8)  // grows with chaos
  }

  private var jitterX: CGFloat {
    guard beatFlash else { return 0 }
    let seed = Double((beatCount * 17 + index * 31) % 100) / 100.0
    return CGFloat(seed - 0.5) * CGFloat(intensity) * 60
  }

  private var jitterY: CGFloat {
    guard beatFlash else { return 0 }
    let seed = Double((beatCount * 23 + index * 13) % 100) / 100.0
    return CGFloat(seed - 0.5) * CGFloat(intensity) * 40
  }

  private var wordOpacity: Double {
    // Flicker: sometimes disappear on beat
    if beatFlash && (beatCount + index) % 5 == 0 && intensity > 0.5 {
      return 0.05  // near-invisible flicker
    }
    return 0.3 + intensity * 0.6
  }

  private var rotation: Double {
    guard intensity > 0.3 else { return 0 }
    let seed = Double((beatCount * 7 + index * 11) % 200) / 200.0
    return (seed - 0.5) * intensity * 15
  }

  var body: some View {
    Text(text)
      .font(
        .system(
          size: fontSize,
          weight: intensity > 0.7 ? .black : (intensity > 0.4 ? .bold : .medium),
          design: .rounded
        )
      )
      .opacity(wordOpacity)
      .position(x: baseX + jitterX, y: baseY + jitterY)
      .rotationEffect(.degrees(rotation))
      .animation(.easeOut(duration: 0.05), value: beatFlash)
  }
}
