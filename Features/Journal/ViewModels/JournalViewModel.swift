import SwiftUI

@Observable
@MainActor
class JournalViewModel {
  var entries: [JournalEntry] = []
  var filteredEntries: [JournalEntry] = []
  var selectedFilter: JournalMood? = nil  // nil = All

  // Grouped items for the view (Month/Year -> Items)
  var selectedDate: Date? = nil  // nil = All dates in the current month
  var currentMonth: Date = Date()  // Defaults to now

  // Grouped items for the view (Month/Year -> Items)
  var groupedEntries: [(String, [JournalEntry])] = []

  init() {
    loadData()
  }

  func loadData() {
    entries = JournalStorage.shared.entries

    // Initialize view with latest entry
    if let latest = entries.max(by: { $0.date < $1.date }) {
      currentMonth = latest.date
      // Calculate week index (Days 1-7 = 0, 8-14 = 1, etc.)
      let day = Calendar.current.component(.day, from: latest.date)
      selectedWeekIndex = (day - 1) / 7
    } else {
      // Default to today if no entries
      currentMonth = Date()
      let day = Calendar.current.component(.day, from: Date())
      selectedWeekIndex = (day - 1) / 7
    }

    applyFilter()
  }

  func nextMonth() {
    guard let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) else {
      return
    }
    currentMonth = newDate
    selectedDate = nil
    applyFilter()
  }

  func prevMonth() {
    guard let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) else {
      return
    }
    currentMonth = newDate
    selectedDate = nil
    applyFilter()
  }

  func applyFilter() {
    updateTotalWeeks()
    var result = entries.sorted { $0.date > $1.date }

    // 0. Filter by Current Month
    let calendar = Calendar.current
    guard let interval = calendar.dateInterval(of: .month, for: currentMonth) else { return }

    result = result.filter {
      $0.date >= interval.start && $0.date < interval.end
    }

    // 1. Filter by Mood
    if let filter = selectedFilter {
      result = result.filter { $0.mood == filter }
    }

    // 2. Filter by Date
    if let date = selectedDate {
      result = result.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    filteredEntries = result
    groupItems(filteredEntries)

    // Check for Crisis Insight
    checkForInsight(result.first)
  }

  // Suggestion State
  // Suggestion State
  var activeSuggestion: SuggestionType? = nil

  enum SuggestionType: Identifiable {
    case shield, breathing, practice
    var id: Self { self }

    var title: String {
      switch self {
      case .shield: return "Your Shield is ready."
      case .breathing: return "Take a deep breath."
      case .practice: return "Try a quick practice?"
      }
    }

    var subtitle: String {
      switch self {
      case .shield: return "Review your plan for peace of mind."
      case .breathing: return "Center yourself in 30 seconds."
      case .practice: return "Build your confidence now."
      }
    }

    var icon: String {
      switch self {
      case .shield: return "shield.fill"
      case .breathing: return "wind"
      case .practice: return "figure.mind.and.body"
      }
    }

    var color: Color {
      switch self {
      case .shield: return DesignSystem.Colors.warmCoral
      case .breathing: return DesignSystem.Colors.calmTeal
      case .practice: return DesignSystem.Colors.calmTeal
      }
    }
  }

  private func checkForInsight(_ latestEntry: JournalEntry?) {
    guard let entry = latestEntry else {
      activeSuggestion = nil
      return
    }

    let calendar = Calendar.current
    if !calendar.isDateInToday(entry.date) {
      activeSuggestion = nil
      return
    }

    switch entry.mood {
    case .anxious, .sad:
      activeSuggestion = .shield
    case .tired:
      activeSuggestion = .breathing
    case .neutral:
      activeSuggestion = .practice  // Gentle nudge
    default:
      activeSuggestion = nil
    }
  }

  // ... (previous functions) ...

  func updateFilter(_ mood: JournalMood?) {
    selectedFilter = mood
    applyFilter()
  }

  func selectDate(_ date: Date?) {
    if let date = date, let current = selectedDate,
      Calendar.current.isDate(date, inSameDayAs: current)
    {
      selectedDate = nil
    } else {
      selectedDate = date
    }
    applyFilter()
  }

  func deleteEntry(_ id: UUID) {
    JournalStorage.shared.deleteEntry(id: id)
    loadData()
  }

  private func groupItems(_ items: [JournalEntry]) {
    let grouped = Dictionary(grouping: items) { item -> String in
      let formatter = DateFormatter()
      formatter.dateFormat = "MMMM yyyy"
      return formatter.string(from: item.date)
    }

    let sortedGroups = grouped.sorted { (first, second) -> Bool in
      guard let firstDate = first.value.first?.date, let secondDate = second.value.first?.date
      else { return false }
      return firstDate > secondDate
    }

    groupedEntries = sortedGroups.map { ($0.key, $0.value) }
  }

  // Weekly Flow Logic
  var selectedWeekIndex: Int = 0  // 0-based index of the week within the month view
  var totalWeeks: Int = 5  // Will be updated when generating heatmap data or on load

  // Helper to sync totalWeeks with HeatmapView logic
  func updateTotalWeeks() {
    let calendar = Calendar.current
    let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 30

    // Week 1 = Days 1-7, Week 2 = Days 8-14...
    // Max days 31: 31/7 = 4.42 -> 5 weeks.
    // Feb 28: 28/7 = 4.0 -> 4 weeks.
    totalWeeks = Int(ceil(Double(daysInMonth) / 7.0))
    // Ensure selected index is valid
    if selectedWeekIndex >= totalWeeks {
      selectedWeekIndex = 0
    }
  }

  struct DailyMoodStat: Identifiable {
    let id = UUID()
    let date: Date
    let mood: JournalMood?
    let isInMonth: Bool

    var value: Double {
      switch mood {
      case .happy: return 1.0
      case .calm: return 0.8
      case .neutral: return 0.5
      case .tired: return 0.3
      case .anxious, .sad: return 0.1
      case .none: return 0.0
      }
    }

    var color: Color {
      guard let m = mood else { return DesignSystem.Colors.glassBorder }
      return Color(hex: m.colorHex)
    }
  }

  var weeklyStats: [DailyMoodStat] {
    let calendar = Calendar.current

    // Get start of the month
    guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
      return []
    }
    let startDate = monthInterval.start

    // Calculate start of the selected week (1-7, 8-14, etc.)
    guard
      let weekStartDate = calendar.date(byAdding: .day, value: selectedWeekIndex * 7, to: startDate)
    else { return [] }

    var stats: [DailyMoodStat] = []

    for i in 0..<7 {
      if let date = calendar.date(byAdding: .day, value: i, to: weekStartDate) {
        // Check if date is in the current month
        let isInMonth = calendar.isDate(date, equalTo: startDate, toGranularity: .month)

        if !isInMonth {
          stats.append(DailyMoodStat(date: date, mood: nil, isInMonth: false))
          continue
        }

        // Find entries for this day
        // Optimization: filteredEntries is limited to this month, but we need accurate daily data
        // Let's use entries directly to be safe about bleeding days
        let dayEntries = entries.filter { calendar.isDate($0.date, inSameDayAs: date) }

        // Take the latest entry for the day
        let lastEntry = dayEntries.max(by: { $0.date < $1.date })
        stats.append(DailyMoodStat(date: date, mood: lastEntry?.mood, isInMonth: true))
      }
    }
    return stats
  }
}
