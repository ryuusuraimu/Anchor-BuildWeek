import SwiftUI

struct CrisisInsightCard: View {
  let suggestion: JournalViewModel.SuggestionType
  let onDismiss: () -> Void
  let onAction: () -> Void

  var body: some View {
    GlassCard {
      VStack(alignment: .leading, spacing: 12) {
        HStack(alignment: .top) {
          HStack(spacing: 12) {
            Image(systemName: suggestion.icon)
              .font(.title2)
              .foregroundColor(suggestion.color)
              .frame(width: 40, height: 40)
              .background(suggestion.color.opacity(0.15))
              .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
              Text(suggestion.title)
                .font(DesignSystem.Fonts.headline())
                .foregroundColor(DesignSystem.Colors.deepText)

              Text(suggestion.subtitle)
                .font(DesignSystem.Fonts.caption())
                .foregroundColor(DesignSystem.Colors.softText)
            }
          }

          Spacer()

          Button(action: onDismiss) {
            Image(systemName: "xmark")
              .font(DesignSystem.Fonts.caption())
              .foregroundColor(DesignSystem.Colors.softText)
              .padding(8)
          }
        }

        Button(action: onAction) {
          Text("Open")
            .font(DesignSystem.Fonts.caption())
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(suggestion.color)
            .cornerRadius(12)
        }
      }
    }
    .padding(.horizontal, 24)
  }
}
