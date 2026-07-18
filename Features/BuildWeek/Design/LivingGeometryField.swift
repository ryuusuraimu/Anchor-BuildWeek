import SwiftUI

#if canImport(RiveRuntime)
  import RiveRuntime
#endif

/// The calm-state motion surface for Home and Reset.
///
/// Home always uses the native Human Signal field. Reset can adopt a reviewed Rive
/// export if the runtime is re-enabled later; its native Canvas field remains the
/// deterministic offline path, so Shield never depends on motion or a network request.
struct LivingGeometryField: View {
  let theme: AppTheme
  let mode: ResponsiveFieldMode
  var engagement = 0.0
  var isPaused = false
  var phaseOrigin: Date? = nil
  var elapsedOffset: TimeInterval = 0
  var frozenPhase: Double? = nil

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.scenePhase) private var scenePhase

  var body: some View {
    Group {
      if mode == .resting {
        HumanSignalHomeField(engagement: engagement)
      } else {
        responsiveField
      }
    }
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }

  @ViewBuilder
  private var responsiveField: some View {
    #if canImport(RiveRuntime)
      if !reduceMotion && Self.hasRiveAsset {
        AnchorRiveGeometryView(
          theme: theme,
          mode: mode,
          engagement: engagement,
          isPaused: isPaused || scenePhase != .active
        )
      } else {
        canvasFallback
      }
    #else
      canvasFallback
    #endif
  }

  private var canvasFallback: some View {
    ResponsiveShelterField(
      theme: theme,
      mode: mode,
      engagement: engagement,
      isAnimated: !isPaused,
      phaseOrigin: phaseOrigin,
      elapsedOffset: elapsedOffset,
      frozenPhase: frozenPhase
    )
    .animation(
      isPaused || reduceMotion
        ? nil
        : engagement > 0.5
          ? .spring(response: 0.48, dampingFraction: 0.90)
          : .smooth(duration: 0.78),
      value: engagement
    )
  }

  private static var hasRiveAsset: Bool {
    Bundle.main.url(forResource: "AnchorLivingGeometry", withExtension: "riv") != nil
  }
}

#if canImport(RiveRuntime)
  @MainActor
  private struct AnchorRiveGeometryView: View {
    let theme: AppTheme
    let mode: ResponsiveFieldMode
    let engagement: Double
    let isPaused: Bool

    @StateObject private var viewModel = RiveViewModel(
      fileName: "AnchorLivingGeometry",
      stateMachineName: "LivingGeometry"
    )

    var body: some View {
      viewModel.view()
        .onAppear {
          viewModel.setPreferredFramesPerSecond(preferredFramesPerSecond: 60)
          synchronizeState()
          updatePlayback()
        }
        .onChange(of: theme) { _, _ in
          synchronizeState()
        }
        .onChange(of: mode) { _, _ in
          synchronizeState()
        }
        .onChange(of: engagement) { _, _ in
          synchronizeState()
        }
        .onChange(of: isPaused) { _, _ in
          updatePlayback()
        }
    }

    private func synchronizeState() {
      viewModel.setInput("theme", value: theme == .luminous ? 1.0 : 0.0)
      viewModel.setInput("mode", value: mode == .active ? 1.0 : 0.0)
      viewModel.setInput("engagement", value: min(max(engagement, 0), 1))
    }

    private func updatePlayback() {
      if isPaused {
        viewModel.pause()
      } else {
        viewModel.play()
      }
    }
  }
#endif
