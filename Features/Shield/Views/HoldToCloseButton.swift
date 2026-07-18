import SwiftUI
import UIKit

struct HoldToCloseButton: View {
  let action: () -> Void
  var hapticsEnabled = true

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var progress: CGFloat = 0.0
  @State private var isPressing = false
  @State private var timer: Timer?
  @State private var assistiveCloseIsArmed = false

  private let pressDuration: TimeInterval = 1.5
  private let feedback = UIImpactFeedbackGenerator(style: .medium)

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("Close")
        .font(.body.weight(.semibold))
        .foregroundStyle(Color.white)
        .fixedSize(horizontal: true, vertical: true)

      ZStack(alignment: .leading) {
        Capsule()
          .fill(Color.white.opacity(isPressing ? 0.24 : 0))

        Capsule()
          .fill(Color.white)
          .scaleEffect(x: progress, y: 1, anchor: .leading)
      }
      .frame(width: 84, height: 3)
      .accessibilityHidden(true)
    }
    .frame(width: 108, height: 52, alignment: .leading)
    .dynamicTypeSize(.xSmall ... .accessibility2)
    .contentShape(Rectangle())
    .gesture(
      DragGesture(minimumDistance: 0)
        .onChanged { _ in
          if !isPressing {
            startPress()
          }
        }
        .onEnded { _ in
          cancelPress()
        }
    )
    .accessibilityElement(children: .ignore)
    .accessibilityAddTraits(.isButton)
    .accessibilityAction {
      activateWithAssistiveTechnology()
    }
    .onDisappear {
      timer?.invalidate()
      timer = nil
      assistiveCloseIsArmed = false
    }
  }

  private func startPress() {
    isPressing = true
    if hapticsEnabled {
      feedback.prepare()
    }
    progress = 0.0

    // The underline communicates the required hold and remains visible when
    // decorative motion is reduced.
    withAnimation(.linear(duration: pressDuration)) {
      progress = 1.0
    }

    // Timer only for the completion trigger
    timer = Timer.scheduledTimer(withTimeInterval: pressDuration, repeats: false) { _ in
      Task { @MainActor in
        self.complete()
      }
    }
  }

  private func cancelPress() {
    isPressing = false
    timer?.invalidate()
    timer = nil

    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
      progress = 0.0
    }
  }

  private func complete() {
    timer?.invalidate()
    timer = nil

    if hapticsEnabled {
      feedback.impactOccurred(intensity: 0.65)
    }

    // Small delay to show completion before dismissing
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      action()
      // Reset state silently
      isPressing = false
      progress = 0.0
    }
  }

  private func activateWithAssistiveTechnology() {
    timer?.invalidate()
    timer = nil
    isPressing = false
    progress = 0.0

    guard assistiveCloseIsArmed else {
      assistiveCloseIsArmed = true
      UIAccessibility.post(
        notification: .announcement,
        argument: "Close is ready. Double-tap again to leave the Shield."
      )
      DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
        assistiveCloseIsArmed = false
      }
      return
    }

    assistiveCloseIsArmed = false
    action()
  }
}
