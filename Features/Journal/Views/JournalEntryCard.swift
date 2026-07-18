import SwiftUI

struct JournalEntryCard: View {
  let entry: JournalEntry

  var body: some View {
    // "Floating Paper" Design
    HStack(alignment: .top, spacing: 16) {
      // Mood Column (Timeline Node)
      VStack(spacing: 4) {
        ZStack {
          Circle()
            .fill(Color(hex: entry.mood.colorHex).opacity(0.15))
            .frame(width: 40, height: 40)

          Image(systemName: entry.mood.icon)
            .font(.system(size: 18))
            .foregroundColor(Color(hex: entry.mood.colorHex))
        }
      }
      .padding(.top, 2)  // Align visually with text cap height

      // Content Column
      VStack(alignment: .leading, spacing: 8) {
        // Header
        HStack(alignment: .firstTextBaseline) {
          Text(entry.mood.rawValue)
            .font(DesignSystem.Fonts.headline())  // 17pt, Semibold
            .foregroundColor(DesignSystem.Colors.deepText)

          Spacer()

          Text(formattedDateString)
            .font(DesignSystem.Fonts.caption())
            .foregroundColor(DesignSystem.Colors.softText.opacity(0.8))
        }

        // Body Text (Editorial style: clean, breathable)
        Text(entry.text)
          .font(DesignSystem.Fonts.body())
          .foregroundColor(DesignSystem.Colors.deepText.opacity(0.85))
          .lineSpacing(4)  // More breathing room
          .lineLimit(4)
          .fixedSize(horizontal: false, vertical: true)
      }
      .padding(16)
      .background(Color.white)
      .cornerRadius(16)
      // Soft ambient shadow
      .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(Color.white.opacity(0.5), lineWidth: 1)
      )
    }
  }

  private var formattedDateString: String {
    let dateStats = entry.date.formatted(
      .dateTime.month(.abbreviated).day().locale(Locale(identifier: "en_US")))
    let weekday = entry.date.formatted(
      .dateTime.weekday(.abbreviated).locale(Locale(identifier: "en_US")))
    let time = entry.date.formatted(date: .omitted, time: .shortened)

    return "\(dateStats) \(weekday) \(time)"
  }
}
