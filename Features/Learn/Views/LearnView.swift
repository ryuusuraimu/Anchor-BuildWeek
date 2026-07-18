import SwiftUI
import UIKit

struct LearnView: View {
  // Appendix B Content
  private let items: [LearnItem] = LearnContent.items

  var body: some View {
    NavigationStack {
      ZStack {
        // Background
        OrganicBackgroundView()

        VStack(spacing: 0) {
          // Custom Header
          HStack {
            Text("Learn")
              .font(DesignSystem.Fonts.hero())
              .foregroundColor(DesignSystem.Colors.deepText)

            Spacer()

            Image(systemName: "book.fill")
              .font(.title)
              .foregroundColor(DesignSystem.Colors.calmTeal)
          }
          .padding(.horizontal, 24)
          .padding(.top, 24)
          .padding(.bottom, 16)

          ScrollView {
            VStack(spacing: 32) {
              AnchorIllustrationPanel(
                title: "Support is easier when it is prepared.",
                subtitle: "Short cards for calm, practical help.",
                icon: "heart.text.square"
              )

              ForEach(LearnCategory.allCases) { category in
                VStack(alignment: .leading, spacing: 16) {
                  Text(category.rawValue)
                    .font(DesignSystem.Fonts.headline())
                    .foregroundColor(DesignSystem.Colors.softText)
                    .padding(.horizontal, 4)

                  ForEach(items.filter { $0.category == category }) { item in
                    LearnCard(item: item)
                  }
                }
              }
            }
            .padding(24)
            .padding(.bottom, 40)
          }
        }
      }
      .navigationBarHidden(true)
    }
  }
}

struct LearnCard: View {
  let item: LearnItem

  private var lockScreenSimulatorNote: String? {
    guard item.title == "Lock Screen Card" else { return nil }
    guard RuntimeEnvironment.isSimulator else { return nil }

    if RuntimeEnvironment.isIPhone {
      return "Note: iPhone Simulator may not show the lock screen / Now Playing UI reliably (even when Safari plays video). Verify on a real iPhone."
    }
    return "Note: Simulator behavior varies by device type and OS version. It may work on iPad Simulator, but iPhone Simulator often doesn't show it reliably. Verify on a real iPhone."
  }

  var body: some View {
    GlassCard {
      VStack(alignment: .leading, spacing: 16) {
        // Header
        HStack(alignment: .top, spacing: 12) {
          Image(systemName: item.icon)
            .font(.title3)
            .foregroundColor(item.color)
            .frame(width: 40, height: 40)
            .background(item.color.opacity(0.1), in: Circle())

          Text(item.title)
            .font(DesignSystem.Fonts.title())
            .foregroundColor(DesignSystem.Colors.deepText)
            .fixedSize(horizontal: false, vertical: true)

          Spacer()
        }

        Divider()
          .background(DesignSystem.Colors.glassBorder)

        // Content
        VStack(alignment: .leading, spacing: 12) {
          InfoRow(label: "When", text: item.when, color: DesignSystem.Colors.softText)
          InfoRow(label: "Why", text: item.why, color: DesignSystem.Colors.calmTeal)
          InfoRow(label: "Do", text: item.todo, color: DesignSystem.Colors.warmCoral)

          if let note = lockScreenSimulatorNote {
            Text(note)
              .font(DesignSystem.Fonts.caption())
              .foregroundColor(DesignSystem.Colors.softText)
              .fixedSize(horizontal: false, vertical: true)
              .padding(.top, 4)
          }
        }

        // Say This (Read-only)
        if !item.sayThis.isEmpty {
          VStack(alignment: .leading, spacing: 8) {
            Text("Say this:")
              .font(DesignSystem.Fonts.caption())
              .fontWeight(.bold)
              .foregroundColor(DesignSystem.Colors.softText)
              .textCase(.uppercase)

            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 8) {
                ForEach(item.sayThis, id: \.self) { phrase in
                  Text(phrase)
                    .font(DesignSystem.Fonts.caption())
                    .foregroundColor(DesignSystem.Colors.deepText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(8)
                    .overlay(
                      RoundedRectangle(cornerRadius: 8)
                        .stroke(DesignSystem.Colors.glassBorder, lineWidth: 1)
                    )
                }
              }
            }
          }
          .padding(.top, 4)
        }

      }
    }
  }
}

// Helper for Identifiable String presentation
struct FullScreenPhrase: Identifiable {
  let id = UUID()
  let text: String
}

struct SayThisFullScreenView: View {
  let text: String
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      VStack {
        HStack {
          Spacer()
          Button(action: { dismiss() }) {
            Image(systemName: "xmark.circle.fill")
              .font(.system(size: 32))
              .foregroundColor(.white.opacity(0.6))
              .padding()
          }
        }
        Spacer()
      }

      Text(text)
        .font(.system(size: 40, weight: .bold, design: .rounded))
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
        .padding()
        .minimumScaleFactor(0.5)
    }
    .onTapGesture {
      dismiss()
    }
  }
}

struct InfoRow: View {
  let label: String
  let text: String
  let color: Color

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 10) {
      Text(label + ":")
        .font(DesignSystem.Fonts.caption())
        .fontWeight(.bold)
        .foregroundColor(color)
        .frame(width: 48, alignment: .leading)
      Text(text)
        .font(DesignSystem.Fonts.body())
        .foregroundColor(DesignSystem.Colors.deepText)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
}

public struct LearnCategorySheet: View {
  let category: LearnCategory
  @Environment(\.dismiss) private var dismiss

  public init(category: LearnCategory) {
    self.category = category
  }

  public var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {
          ForEach(LearnContent.items.filter { $0.category == category }) { item in
            LearnCard(item: item)
          }
        }
        .padding(24)
      }
      .background(DesignSystem.Colors.offWhite)
      .navigationTitle(category.rawValue)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") {
            dismiss()
          }
          .font(DesignSystem.Fonts.body())
          .foregroundColor(DesignSystem.Colors.calmTeal)
        }
      }
    }
  }
}

#Preview {
  LearnView()
}
