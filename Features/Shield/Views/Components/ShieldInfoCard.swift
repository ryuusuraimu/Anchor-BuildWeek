import SwiftUI

struct ShieldInfoCard: View {
  let title: String
  let text: String
  let tintColor: Color
  let icon: String?
  var onInfoTap: (() -> Void)? = nil

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        if let icon = icon {
          Image(systemName: icon)
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(tintColor.opacity(0.8))
        }

        Text(title)
          .font(DesignSystem.Fonts.caption())
          .fontWeight(.bold)
          .foregroundColor(tintColor.opacity(0.8))
          .kerning(1.2)
          .textCase(.uppercase)

        Spacer()

        if let onInfoTap = onInfoTap {
          Button(action: onInfoTap) {
            Image(systemName: "info.circle")
              .font(.system(size: 16))
              .foregroundColor(tintColor.opacity(0.8))
              .padding(4)
              .background(Color.white.opacity(0.1), in: Circle())
          }
        }
      }

      Text(text)
        .font(.system(size: 20, weight: .semibold, design: .rounded))
        .foregroundColor(DesignSystem.Colors.offWhite)
        .lineSpacing(2)
        .minimumScaleFactor(0.5)
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(16)
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(tintColor.opacity(0.3), lineWidth: 1)
    )
  }
}

#Preview {
  ZStack {
    Color.black.ignoresSafeArea()
    ShieldInfoCard(
      title: "SITUATION",
      text: "I feel overwhelmed and cannot speak clearly.",
      tintColor: DesignSystem.Colors.calmTeal,
      icon: "exclamationmark.triangle.fill"
    )
    .padding()
  }
}
