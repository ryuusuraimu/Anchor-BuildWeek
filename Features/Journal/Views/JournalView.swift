import SwiftUI

struct JournalView: View {
  @State private var viewModel = JournalViewModel()
  @State private var showCompose = false
  @State private var showCalendar = false
  @State private var showBreathing = false
  @State private var preselectedMood: JournalMood?

  var body: some View {
    NavigationStack {
      ZStack {
        // Background
        OrganicBackgroundView()

        VStack(spacing: 0) {
          ScrollView {
            VStack(spacing: 32) {
              headerSection
              filterSection
              timelineSection
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }
        }

        crisisInsightOverlay
      }
      .buttonStyle(.plain)
      .navigationBarHidden(true)
      .onAppear { viewModel.loadData() }
      .sheet(isPresented: $showCompose) {
        JournalComposeView { text, mood in
          JournalStorage.shared.addEntry(text: text, mood: mood)
          viewModel.loadData()
        }
      }
      .sheet(isPresented: $showCalendar) {
        CalendarFilterSheet(selectedDate: $viewModel.selectedDate)
          .presentationDetents([.medium, .fraction(0.7)])
          .onChange(of: viewModel.selectedDate) { _, _ in
            viewModel.applyFilter()
          }
      }
      .fullScreenCover(isPresented: $showBreathing) {
        BreathingView()
      }
    }
  }

  // MARK: - Subviews

  private var headerSection: some View {
    JournalBentoGrid(
      viewModel: viewModel,
      onCheckIn: {
        preselectedMood = nil
        showCompose = true
      },
      onOpenCalendar: {
        showCalendar = true
      }
    )
    .padding(.top, 24)
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var filterSection: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        FilterButton(title: "All Entries", isSelected: viewModel.selectedFilter == nil) {
          viewModel.updateFilter(nil)
        }
        ForEach(JournalMood.allCases) { mood in
          FilterButton(title: mood.rawValue, isSelected: viewModel.selectedFilter == mood) {
            viewModel.updateFilter(mood)
          }
        }
      }
      .padding(.horizontal, 24)
    }
  }

  private var timelineSection: some View {
    Group {
      if viewModel.entries.isEmpty {
        EmptyStateView()
      } else {
        LazyVStack(spacing: 24) {
          ForEach(viewModel.groupedEntries, id: \.0) { (month, items) in
            VStack(alignment: .leading, spacing: 16) {
              Text(month)
                .font(DesignSystem.Fonts.headline())
                .foregroundColor(DesignSystem.Colors.softText)
                .padding(.horizontal, 24)

              ForEach(Array(items.enumerated()), id: \.element.id) { index, entry in
                TimelineItemView(
                  entry: entry,
                  isLast: index == items.count - 1,
                  onDelete: {
                    withAnimation { viewModel.deleteEntry(entry.id) }
                  }
                )
              }
            }
          }
        }
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var crisisInsightOverlay: some View {
    Group {
      if let suggestion = viewModel.activeSuggestion {
        VStack {
          Spacer()
          CrisisInsightCard(
            suggestion: suggestion,
            onDismiss: {
              withAnimation { viewModel.activeSuggestion = nil }
            },
            onAction: {
              withAnimation { viewModel.activeSuggestion = nil }
              handleSuggestionAction(suggestion)
            }
          )
          .transition(.move(edge: .bottom).combined(with: .opacity))
          .padding(.bottom, 20)
        }
      }
    }
  }

  func formattedDate() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMMM d"
    return formatter.string(from: Date())
  }

  @MainActor
  func handleSuggestionAction(_ suggestion: JournalViewModel.SuggestionType) {
    switch suggestion {
    case .breathing:
      showBreathing = true
    case .shield:
      AppRoutes.open(AppRoutes.shield)
    case .practice:
      AppRoutes.open(AppRoutes.practice)
    }
  }
}

// Subcomponents

struct EmptyStateView: View {
  var body: some View {
    VStack(spacing: 18) {
      AnchorIllustrationPanel(
        title: "Reflect privately after hard moments.",
        subtitle: "Your journal starts empty and stays on this device.",
        icon: "book.pages",
        minHeight: 170
      )

      Text("Add a note when you are ready.")
        .font(DesignSystem.Fonts.body())
        .foregroundColor(DesignSystem.Colors.softText)
        .multilineTextAlignment(.center)
    }
    .padding(.horizontal, 24)
    .padding(.top, 8)
    .padding(.bottom, 40)
    .frame(maxWidth: .infinity)
  }
}

struct TimelineItemView: View {
  let entry: JournalEntry
  let isLast: Bool
  let onDelete: () -> Void

  var body: some View {
    HStack(alignment: .top, spacing: 0) {
      // Timeline
      VStack(spacing: 0) {
        Circle()
          .fill(Color(hex: entry.mood.colorHex))
          .frame(width: 12, height: 12)
          .background(
            Circle()
              .fill(Color.white)
              .frame(width: 20, height: 20)
              .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
          )
          .padding(.top, 18)

        if !isLast {
          Rectangle()
            .fill(DesignSystem.Colors.softText.opacity(0.2))
            .frame(width: 2)
            .frame(maxHeight: .infinity)
        }
      }
      .frame(width: 40)

      // Card
      JournalEntryCard(entry: entry)
        .padding(.leading, 8)
        .padding(.bottom, 24)
        .padding(.trailing, 24)
        .contextMenu {
          Button(role: .destructive, action: onDelete) {
            Label("Delete", systemImage: "trash")
          }
        }
    }
    .padding(.leading, 20)
  }
}

struct FilterButton: View {
  let title: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: {
      withAnimation { action() }
    }) {
      Text(title)
        .font(DesignSystem.Fonts.caption())
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
          isSelected
            ? DesignSystem.Colors.calmTeal
            : DesignSystem.Colors.glassSurface,
          in: Capsule()
        )
        .foregroundColor(
          isSelected
            ? .white
            : DesignSystem.Colors.deepText
        )
        .overlay(
          Capsule()
            .stroke(DesignSystem.Colors.glassBorder, lineWidth: 1)
        )
    }
    .buttonStyle(.plain)
  }
}

struct BentoCard<Content: View>: View {
  let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    GlassCard {
      content
    }
  }
}
