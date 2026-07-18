import SwiftUI

struct HomeDashboardView: View {
  let shieldScore: Double
  let supporterScore: Double
  let practiceScore: Double

  // Actions
  var onTapShield: () -> Void
  var onTapSupporter: () -> Void
  var onTapJournal: () -> Void

  var body: some View {
    VStack(spacing: 16) {
      // 2. Status Grid (Bottom)
      ViewThatFits(in: .horizontal) {
        HStack(spacing: 16) {
          shieldCard
          contactCard
        }

        VStack(spacing: 12) {
          shieldCard
          contactCard
        }
      }
      // Practice is intentionally omitted here to keep the dashboard lightweight.
    }
    .padding(.horizontal, DesignSystem.Layout.screenPadding)
  }

  private var shieldCard: some View {
    StatCard(
      icon: "shield.fill",
      title: "Shield",
      value: shieldScore >= 1.0 ? "Active" : "Setup",
      color: DesignSystem.Colors.calmTeal,
      isCompleted: shieldScore >= 1.0,
      action: onTapShield
    )
  }

  private var contactCard: some View {
    StatCard(
      icon: "person.2.fill",
      title: "Contact",
      value: supporterScore >= 1.0 ? "Ready" : "Add",
      color: DesignSystem.Colors.warmCoral,
      isCompleted: supporterScore >= 1.0,
      action: onTapSupporter
    )
  }
}

// MARK: - Components

struct StatCard: View {
  let icon: String
  let title: String
  let value: String
  let color: Color
  let isCompleted: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(alignment: .leading, spacing: 12) {
        Image(systemName: icon)
          .font(.system(size: 24))
          .foregroundColor(isCompleted ? color : DesignSystem.Colors.softText)

        VStack(alignment: .leading, spacing: 4) {
          Text(title)
            .font(DesignSystem.Fonts.caption())
            .foregroundColor(DesignSystem.Colors.softText)

          Text(value)
            .font(DesignSystem.Fonts.headline())  // Bold value
            .foregroundColor(DesignSystem.Colors.deepText)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(minHeight: 88, alignment: .leading)
      .padding(16)
      .background(Color.white)
      .cornerRadius(20)
      .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
  }
}

// Extension for Gold color if not in DesignSystem
extension DesignSystem.Colors {
  static let gold = Color(hex: "D4AF37")  // Classic Gold
}
