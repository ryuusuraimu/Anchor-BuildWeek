import SwiftUI

struct BreathingView: View {
  @Environment(\.dismiss) var dismiss
  @State private var idleTimer = IdleTimerService()
  @State private var phase: BreathingPhase = .inhale
  @State private var scale: CGFloat = 1.0
  @State private var opacity: Double = 0.5
  @State private var rotation: Double = 0
  @State private var timeRemaining = 120  // 2 minutes
  @State private var isCompleted = false

  enum BreathingPhase {
    case inhale, hold, exhale, holdOut

    var instruction: String {
      switch self {
      case .inhale: return "Inhale..."
      case .hold: return "Hold..."
      case .exhale: return "Exhale..."
      case .holdOut: return "Settle..."
      }
    }

    var color: Color {
      // Teal/Cyan across the board for the "energy" look, slightly varying brightness if needed
      return Color(red: 0.2, green: 0.8, blue: 0.9)
    }

    var duration: TimeInterval {
      switch self {
      case .inhale: return 4.0
      case .hold: return 4.0
      case .exhale: return 4.0
      case .holdOut: return 2.0
      }
    }
  }

  var body: some View {
    ZStack {
      // Dark Background
      Color.black.ignoresSafeArea()

      // Subtle gradient
      RadialGradient(
        gradient: Gradient(colors: [
          Color(red: 0.1, green: 0.3, blue: 0.4).opacity(0.3),
          Color.black,
        ]),
        center: .center,
        startRadius: 5,
        endRadius: 300
      )
      .ignoresSafeArea()

      if isCompleted {
        // Completion Screen
        VStack(spacing: 32) {
          Spacer()

          Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 80))
            .foregroundColor(DesignSystem.Colors.calmTeal)
            .shadow(color: DesignSystem.Colors.calmTeal.opacity(0.5), radius: 20)

          VStack(spacing: 16) {
            Text("Session Complete")
              .font(DesignSystem.Fonts.hero())
              .foregroundColor(.white)

            Text("You've taken a moment for yourself.\nCarry this calm into your day.")
              .font(DesignSystem.Fonts.body())
              .foregroundColor(.white.opacity(0.8))
              .multilineTextAlignment(.center)
              .padding(.horizontal, 32)
          }

          Spacer()

          Button(action: {
            dismiss()
          }) {
            Text("Done")
              .font(DesignSystem.Fonts.headline())
              .foregroundColor(.black)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 16)
              .background(DesignSystem.Colors.calmTeal)
              .cornerRadius(16)
          }
          .padding(.horizontal, 40)
          .padding(.bottom, 50)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
      } else {
        // Breathing Session
        VStack {
          HStack {
            Button(action: {
              dismiss()
            }) {
              Image(systemName: "xmark")
                .font(DesignSystem.Fonts.headline())
                .foregroundColor(.white.opacity(0.8))
                .padding(12)
                .background(Color.white.opacity(0.1), in: Circle())
            }
            Spacer()
          }
          .padding()

          Spacer()

          ZStack {
            GeometricFlowerView(
              scale: scale,
              opacity: opacity,
              color: phase.color,
              rotation: rotation
            )

            Text(phase.instruction)
              .font(DesignSystem.Fonts.hero())
              .foregroundColor(.white)
              .contentTransition(.opacity)
              .shadow(color: phase.color.opacity(0.5), radius: 10, x: 0, y: 0)
          }

          Spacer()

          Text(timeString(time: timeRemaining))
            .font(DesignSystem.Fonts.title())
            .monospacedDigit()
            .foregroundColor(.white.opacity(0.8))
            .padding(.bottom, 50)
        }
        .transition(.opacity)
      }
    }
    .buttonStyle(NoSelectionButtonStyle())
    .task {
      idleTimer.preventSleep(enabled: true)
      await startSession()
    }
    .onDisappear {
      idleTimer.restore()
    }
  }

  func startSession() async {
    // Start breathing cycle
    // Run loop alongside timer
    await withTaskGroup(of: Void.self) { group in
      group.addTask { await runBreathingCycle() }
      group.addTask { await runTimer() }
    }
  }

  @MainActor
  func runTimer() async {
    while timeRemaining > 0 {
      try? await Task.sleep(nanoseconds: 1_000_000_000)
      if Task.isCancelled { return }
      timeRemaining -= 1
    }
    if timeRemaining == 0 {
      withAnimation(.easeInOut) {
        isCompleted = true
      }
      playHaptic(type: .success)
    }
  }

  @MainActor
  func runBreathingCycle() async {
    // Infinite loop until cancelled
    while !Task.isCancelled && timeRemaining > 0 {
      await animatePhase(.inhale)
      if timeRemaining <= 0 { break }
      await animatePhase(.hold)
      if timeRemaining <= 0 { break }
      await animatePhase(.exhale)
      if timeRemaining <= 0 { break }
      await animatePhase(.holdOut)
      if timeRemaining <= 0 { break }
    }
  }

  @MainActor
  func animatePhase(_ nextPhase: BreathingPhase) async {
    phase = nextPhase
    playHapticForPhase(nextPhase)

    withAnimation(.easeInOut(duration: nextPhase.duration)) {
      switch nextPhase {
      case .inhale:
        scale = 1.0
        opacity = 1.0
        rotation += 45
      case .hold:
        scale = 1.0
        opacity = 0.8
        rotation += 10
      case .exhale:
        scale = 0.5
        opacity = 0.5
        rotation += 45
      case .holdOut:
        scale = 0.5
        opacity = 0.3
        rotation += 5
      }
    }

    // Wait for duration
    let nanoseconds = UInt64(nextPhase.duration * 1_000_000_000)
    try? await Task.sleep(nanoseconds: nanoseconds)
  }

  func timeString(time: Int) -> String {
    let minutes = time / 60
    let seconds = time % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }

  // MARK: - Haptics

  func playHapticForPhase(_ phase: BreathingPhase) {
    switch phase {
    case .inhale:
      let generator = UIImpactFeedbackGenerator(style: .medium)
      generator.impactOccurred()
    case .hold:
      let generator = UIImpactFeedbackGenerator(style: .heavy)
      generator.impactOccurred()
    case .exhale:
      let generator = UIImpactFeedbackGenerator(style: .light)
      generator.impactOccurred()
    case .holdOut:
      break
    }
  }

  func playHaptic(type: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(type)
  }
}

#Preview {
  BreathingView()
}
