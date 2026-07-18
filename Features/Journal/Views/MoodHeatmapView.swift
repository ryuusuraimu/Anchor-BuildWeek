import SwiftUI

struct MoodHeatmapView: View {
  let entries: [JournalEntry]
  let month: Date
  let selectedDate: Date?
  let onSelect: (Date) -> Void

  // Grid columns
  let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Insight Map")
        .font(DesignSystem.Fonts.caption())
        .foregroundColor(DesignSystem.Colors.softText)

      LazyVGrid(columns: columns, spacing: 4) {
        ForEach(generateHeatmapData(), id: \.date) { data in
          if data.isCurrentMonth {
            Button(action: {
              onSelect(data.date)
            }) {
              RoundedRectangle(cornerRadius: 3)
                .fill(
                  data.mood == nil ? Color.black.opacity(0.05) : Color(hex: data.mood!.colorHex)
                )
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                  RoundedRectangle(cornerRadius: 3)
                    .stroke(
                      isSelected(data.date)
                        ? DesignSystem.Colors.activeAction : Color.white.opacity(0.3),
                      lineWidth: isSelected(data.date) ? 2 : 0.5
                    )
                )
                .opacity(selectedDate != nil && !isSelected(data.date) ? 0.3 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
          } else {
            Color.clear
              .aspectRatio(1, contentMode: .fit)
          }
        }
      }
    }
  }

  private func isSelected(_ date: Date) -> Bool {
    guard let selected = selectedDate else { return false }
    return Calendar.current.isDate(selected, inSameDayAs: date)
  }

  private struct HeatmapData {
    let date: Date
    let mood: JournalMood?
    let isCurrentMonth: Bool
  }

  private func generateHeatmapData() -> [HeatmapData] {
    let calendar = Calendar.current

    // Get start of the month
    guard let monthInterval = calendar.dateInterval(of: .month, for: month) else { return [] }
    let startDate = monthInterval.start
    let endDate = monthInterval.end

    // Calculate padding for start of week (Sunday-based)
    let weekday = calendar.component(.weekday, from: startDate)
    let daysToPad = (weekday - calendar.firstWeekday + 7) % 7

    // Start generating from the padding dates
    guard let gridStartDate = calendar.date(byAdding: .day, value: -daysToPad, to: startDate) else {
      return []
    }

    var result: [HeatmapData] = []
    var currentDate = gridStartDate

    // Generate 6 weeks (42 days) to cover all possible month layouts (or just enough)
    for _ in 0..<42 {
      let isCurrentMonth = currentDate >= startDate && currentDate < endDate

      let entry = entries.first { calendar.isDate($0.date, inSameDayAs: currentDate) }
      result.append(
        HeatmapData(date: currentDate, mood: entry?.mood, isCurrentMonth: isCurrentMonth))

      if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
        currentDate = nextDate
      } else {
        break
      }
    }

    return result
  }
}
