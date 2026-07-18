import SwiftUI

// MARK: - Tutorial Step Model

struct TutorialStep: Identifiable {
  let id: Int
  let imageName: String
  let instruction: String
}

// MARK:   TUTORIAL CARD SWIPER — Dating App-style Card Stack

struct TutorialCardSwiper: View {
  let title: String
  let subtitle: String
  let icon: String
  let steps: [TutorialStep]

  @Environment(\.dismiss) private var dismiss
  @State private var currentIndex: Int = 0
  @State private var dragOffset: CGFloat = 0

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        // Header
        headerSection
          .padding(.top, 12)
          .padding(.bottom, 16)

        // Step counter
        stepCounter
          .padding(.bottom, 12)

        // Card stack
        ZStack {
          // Next card (behind, visible as depth hint)
          if currentIndex + 1 < steps.count {
            cardView(for: steps[currentIndex + 1])
              .scaleEffect(0.92)
              .offset(y: 12)
              .opacity(0.6)
              .zIndex(0)
          }

          // Current card (interactive)
          if currentIndex < steps.count {
            cardView(for: steps[currentIndex])
              .offset(x: dragOffset)
              .rotationEffect(.degrees(Double(dragOffset) / 25), anchor: .bottom)
              .gesture(swipeGesture)
              .zIndex(1)
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)

        // Bottom controls
        bottomControls
          .padding(.vertical, 16)
          .padding(.horizontal, 20)
      }
      .background(DesignSystem.Colors.offWhite.ignoresSafeArea())
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") { dismiss() }
            .font(DesignSystem.Fonts.body())
            .foregroundColor(DesignSystem.Colors.calmTeal)
        }
      }
    }
  }

  // MARK: - Header

  private var headerSection: some View {
    VStack(spacing: 8) {
      Image(systemName: icon)
        .font(.system(size: 28))
        .foregroundStyle(DesignSystem.Colors.calmTeal)
        .frame(width: 52, height: 52)
        .background(DesignSystem.Colors.calmTeal.opacity(0.1), in: Circle())

      Text(title)
        .font(DesignSystem.Fonts.title())
        .foregroundStyle(DesignSystem.Colors.deepText)

      Text(subtitle)
        .font(DesignSystem.Fonts.caption())
        .foregroundStyle(DesignSystem.Colors.softText)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
    }
  }

  // MARK: - Step Counter

  private var stepCounter: some View {
    HStack(spacing: 6) {
      ForEach(0..<steps.count, id: \.self) { index in
        Capsule()
          .fill(
            index == currentIndex
              ? DesignSystem.Colors.calmTeal
              : DesignSystem.Colors.softText.opacity(0.2)
          )
          .frame(width: index == currentIndex ? 24 : 8, height: 6)
          .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentIndex)
      }
    }
  }

  // MARK: - Card View

  private func cardView(for step: TutorialStep) -> some View {
    VStack(spacing: 0) {
      // Screenshot image — use SwiftUI Image() for proper .swiftpm bundle resolution
      Image(step.imageName)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipped()

      // Instruction area
      VStack(alignment: .leading, spacing: 6) {
        Text("STEP \(step.id + 1) OF \(steps.count)")
          .font(.system(size: 11, weight: .bold, design: .rounded))
          .foregroundStyle(DesignSystem.Colors.calmTeal)
          .tracking(1.2)

        Text(.init(step.instruction))
          .font(DesignSystem.Fonts.body())
          .foregroundStyle(DesignSystem.Colors.deepText)
          .lineSpacing(3)
          .fixedSize(horizontal: false, vertical: true)
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 16)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
  }

  // MARK: - Swipe Gesture

  private var swipeGesture: some Gesture {
    DragGesture()
      .onChanged { value in
        dragOffset = value.translation.width
      }
      .onEnded { value in
        let threshold: CGFloat = 100
        if value.translation.width < -threshold && currentIndex < steps.count - 1 {
          // Swipe left → next
          withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            currentIndex += 1
            dragOffset = 0
          }
        } else if value.translation.width > threshold && currentIndex > 0 {
          // Swipe right → previous
          withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            currentIndex -= 1
            dragOffset = 0
          }
        } else {
          // Snap back
          withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            dragOffset = 0
          }
        }
      }
  }

  // MARK: - Bottom Controls

  private var bottomControls: some View {
    HStack {
      // Back button
      Button {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
          currentIndex -= 1
          dragOffset = 0
        }
      } label: {
        HStack(spacing: 4) {
          Image(systemName: "chevron.left")
          Text("Back")
        }
        .font(DesignSystem.Fonts.body())
        .foregroundStyle(DesignSystem.Colors.softText)
      }
      .opacity(currentIndex > 0 ? 1 : 0)
      .disabled(currentIndex <= 0)

      Spacer()

      // Swipe hint
      Text("Swipe to navigate")
        .font(.system(size: 12, weight: .medium, design: .rounded))
        .foregroundStyle(DesignSystem.Colors.softText.opacity(0.6))

      Spacer()

      // Next / Done button
      if currentIndex < steps.count - 1 {
        Button {
          withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            currentIndex += 1
            dragOffset = 0
          }
        } label: {
          HStack(spacing: 4) {
            Text("Next")
            Image(systemName: "chevron.right")
          }
          .font(DesignSystem.Fonts.body())
          .foregroundStyle(DesignSystem.Colors.calmTeal)
        }
      } else {
        Button {
          dismiss()
        } label: {
          Text("Done")
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(DesignSystem.Colors.calmTeal)
        }
      }
    }
    .sensoryFeedback(.impact(weight: .light, intensity: 0.4), trigger: currentIndex)
  }
}
