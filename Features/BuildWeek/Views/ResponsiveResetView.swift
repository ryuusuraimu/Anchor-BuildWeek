import Combine
import SwiftUI

struct ResponsiveResetView: View {
  @Environment(SettingsStore.self) private var settings
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.dismiss) private var dismiss

  @ScaledMetric(relativeTo: .largeTitle) private var timerSize: CGFloat = 46

  @State private var remainingSeconds = 120
  @State private var isPaused = false
  @State private var showShield = false
  @State private var motionOrigin = Date()
  @State private var accumulatedPauseDuration: TimeInterval = 0
  @State private var pauseStartedAt: Date?
  @State private var frozenMotionPhase: Double?

  private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  private var palette: ResponsiveShelterPalette {
    settings.selectedTheme.shelterPalette
  }

  private var elapsedSeconds: Int {
    120 - remainingSeconds
  }

  private var instruction: String {
    guard remainingSeconds > 0 else { return "Stay as long as you need" }
    return elapsedSeconds % 8 < 4 ? "Breathe in" : "Breathe out"
  }

  private var formattedTime: String {
    String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
  }

  private var resolvedTimerSize: CGFloat {
    dynamicTypeSize.isAccessibilitySize ? min(timerSize, 58) : timerSize
  }

  private var shouldReduceMotion: Bool {
    #if DEBUG
      if ProcessInfo.processInfo.arguments.contains("-reduceMotionReset") {
        return true
      }
    #endif
    return reduceMotion
  }

  var body: some View {
    ZStack {
      LivingGeometryField(
        theme: settings.selectedTheme,
        mode: .active,
        engagement: 1,
        isPaused: isPaused,
        phaseOrigin: motionOrigin,
        elapsedOffset: accumulatedPauseDuration,
        frozenPhase: frozenMotionPhase
      )
      .ignoresSafeArea()

      if dynamicTypeSize.isAccessibilitySize {
        LinearGradient(
          stops: [
            .init(color: palette.backgroundTop.opacity(0.98), location: 0),
            .init(color: palette.backgroundTop.opacity(0.94), location: 0.62),
            .init(color: Color.clear, location: 0.90),
          ],
          startPoint: .leading,
          endPoint: .trailing
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
      }

      GeometryReader { proxy in
        ScrollView {
          VStack(alignment: .leading, spacing: 0) {
            header

            VStack(alignment: .leading, spacing: 10) {
              Text(formattedTime)
                .font(.system(size: resolvedTimerSize, weight: .light, design: .rounded))
                .monospacedDigit()
                .dynamicTypeSize(.xSmall ... .accessibility2)
                .foregroundStyle(palette.secondaryText)
                .accessibilityLabel("\(remainingSeconds) seconds remaining")

              Text(instruction)
                .font(.largeTitle.weight(.regular))
                .fontDesign(.serif)
                .dynamicTypeSize(.xSmall ... .accessibility2)
                .tracking(-0.7)
                .foregroundStyle(palette.primaryText)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
                .contentTransition(shouldReduceMotion ? .identity : .opacity)

              Text(remainingSeconds > 0 ? "Follow your own pace" : "There is no need to rush back.")
                .font(.title3)
                .dynamicTypeSize(.xSmall ... .accessibility2)
                .foregroundStyle(palette.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, dynamicTypeSize.isAccessibilitySize ? 28 : 44)

            Spacer(minLength: dynamicTypeSize.isAccessibilitySize ? 40 : 72)

            sessionControls
          }
          .frame(minHeight: max(0, proxy.size.height - 40), alignment: .top)
          .padding(.horizontal, BuildWeekDesign.Metric.screenPadding)
          .padding(.top, 8)
          .padding(.bottom, dynamicTypeSize.isAccessibilitySize ? 44 : 24)
        }
        .scrollIndicators(.hidden)
      }
    }
    .preferredColorScheme(.dark)
    .fullScreenCover(isPresented: $showShield) {
      BuildWeekShieldView()
    }
    .onReceive(timer) { _ in
      guard !isPaused, !showShield, remainingSeconds > 0 else { return }
      remainingSeconds -= 1
      if remainingSeconds == 0 {
        pauseSession()
      }
    }
    .onChange(of: showShield) { _, isPresented in
      if isPresented {
        pauseSession()
      }
    }
    .onAppear {
      applyDebugPresentation()
    }
  }

  private var header: some View {
    Group {
      if dynamicTypeSize.isAccessibilitySize {
        VStack(alignment: .leading, spacing: 12) {
          closeButton
          openShieldButton
        }
      } else {
        HStack(spacing: 12) {
          closeButton
          Spacer(minLength: 12)
          openShieldButton
        }
      }
    }
    .font(.body.weight(.semibold))
    .dynamicTypeSize(.xSmall ... .accessibility2)
    .foregroundStyle(palette.primaryText)
    .buttonStyle(.plain)
    .frame(maxWidth: .infinity, alignment: .leading)
    .frame(minHeight: BuildWeekDesign.Metric.shieldUtility)
  }

  private var closeButton: some View {
    Button("Close") { dismiss() }
      .accessibilityHint("Ends this reset and returns Home")
  }

  private var openShieldButton: some View {
    Button {
      showShield = true
    } label: {
      HStack(spacing: 8) {
        Text("Open Shield")
        Image(systemName: "chevron.right")
      }
    }
    .accessibilityHint("Shows your prepared support instructions full screen")
  }

  private var sessionControls: some View {
    ViewThatFits(in: .horizontal) {
      HStack(spacing: 16) {
        pauseButton
        endButton
      }

      VStack(spacing: 12) {
        pauseButton
        endButton
      }
    }
  }

  private var pauseButton: some View {
    Button {
      guard remainingSeconds > 0 else { return }
      if isPaused {
        resumeSession()
      } else {
        pauseSession()
      }
    } label: {
      Label(
        remainingSeconds == 0 ? "Finished" : (isPaused ? "Resume" : "Pause"),
        systemImage: remainingSeconds == 0 ? "checkmark" : (isPaused ? "play.fill" : "pause.fill")
      )
      .font(.body.weight(.semibold))
      .dynamicTypeSize(.xSmall ... .accessibility2)
      .foregroundStyle(palette.primaryText)
      .padding(.horizontal, 22)
      .frame(maxWidth: .infinity)
      .frame(minHeight: 58)
      .background(palette.surface)
      .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .stroke(palette.surfaceBorder, lineWidth: 1)
      }
    }
    .buttonStyle(.plain)
    .disabled(remainingSeconds == 0)
    .accessibilityHint(
      isPaused ? "Continues the two-minute reset" : "Pauses the timer and field motion")
  }

  private func pauseSession() {
    guard !isPaused else { return }
    let now = Date()
    frozenMotionPhase = motionPhase(at: now)
    pauseStartedAt = now
    isPaused = true
  }

  private func resumeSession() {
    guard isPaused else { return }
    let now = Date()
    if let pauseStartedAt {
      accumulatedPauseDuration += now.timeIntervalSince(pauseStartedAt)
    }
    self.pauseStartedAt = nil
    frozenMotionPhase = nil
    isPaused = false
  }

  private func motionPhase(at date: Date) -> Double {
    let elapsed = max(0, date.timeIntervalSince(motionOrigin) - accumulatedPauseDuration)
    return elapsed.truncatingRemainder(dividingBy: 8) / 8
  }

  private func applyDebugPresentation() {
    #if DEBUG
      if ProcessInfo.processInfo.arguments.contains("-pauseReset") {
        DispatchQueue.main.async {
          pauseSession()
        }
      }
    #endif
  }

  private var endButton: some View {
    Button {
      dismiss()
    } label: {
      Text("End session")
        .font(.body.weight(.semibold))
        .dynamicTypeSize(.xSmall ... .accessibility2)
        .foregroundStyle(palette.accent)
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 58)
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
          RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(palette.accent.opacity(0.88), lineWidth: 1)
        }
        .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityHint("Returns Home")
  }
}

#Preview {
  ResponsiveResetView()
    .environment(SettingsStore())
    .environmentObject(EmergencyContactStore())
}
