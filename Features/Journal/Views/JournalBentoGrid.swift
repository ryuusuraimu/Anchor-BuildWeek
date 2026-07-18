import SwiftUI

struct JournalBentoGrid: View {
  var viewModel: JournalViewModel
  let onCheckIn: () -> Void
  let onOpenCalendar: () -> Void

  var body: some View {
    VStack(spacing: 12) {
      // Row 1: Greeting (Large) + Check In (Action)
      ViewThatFits(in: .horizontal) {
        HStack(spacing: 12) {
          greetingCard
          checkInCard
        }

        VStack(spacing: 12) {
          greetingCard
          checkInCard
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      // Row 2: Stats (Weekly Flow + Activity Map)
      ViewThatFits(in: .horizontal) {
        HStack(spacing: 12) {
          flowCard
          heatmapCard
        }

        VStack(spacing: 12) {
          flowCard
          heatmapCard
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(.horizontal, DesignSystem.Layout.screenPadding)
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var greetingCard: some View {
    GlassCard(
      material: .regularMaterial,
      tintOpacity: 0.36,
      borderOpacity: 1.0,
      shadowOpacity: 0.045
    ) {
          VStack(alignment: .leading, spacing: 16) {
            HStack {
              Image(systemName: "sun.max.fill")
                .foregroundColor(DesignSystem.Colors.warmCoral)

              Spacer()

              // Month Navigation
              HStack(spacing: 12) {
                Button(action: {
                  withAnimation { viewModel.prevMonth() }
                }) {
                  Image(systemName: "chevron.left")
                    .font(.caption.bold())
                    .foregroundColor(DesignSystem.Colors.softText)
                    .contentShape(Rectangle())
                }

                Text(viewModel.currentMonth.formatted(.dateTime.month().year()))
                  .font(DesignSystem.Fonts.caption().weight(.semibold))
                  .foregroundColor(DesignSystem.Colors.deepText)
                  .frame(minWidth: 86)
                  .multilineTextAlignment(.center)

                Button(action: {
                  withAnimation { viewModel.nextMonth() }
                }) {
                  Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundColor(DesignSystem.Colors.softText)
                    .contentShape(Rectangle())
                }
                .disabled(
                  Calendar.current.isDate(
                    viewModel.currentMonth, equalTo: Date(), toGranularity: .month)
                )
                .opacity(
                  Calendar.current.isDate(
                    viewModel.currentMonth, equalTo: Date(), toGranularity: .month) ? 0.3 : 1.0)
              }
              .padding(.vertical, 4)
              .padding(.horizontal, 8)
              .background(Color.black.opacity(0.03))
              .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 4) {
              Text("Good Afternoon")
                .font(DesignSystem.Fonts.title())
                .foregroundColor(DesignSystem.Colors.deepText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

              Text("Ready to reflect?")
                .font(DesignSystem.Fonts.body())
                .foregroundColor(DesignSystem.Colors.softText)
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .frame(minHeight: 132, alignment: .topLeading)
        }
    .frame(maxWidth: .infinity)
  }

  private var checkInCard: some View {
    GlassCard(
      material: .regularMaterial,
      tintOpacity: 0.36,
      borderOpacity: 1.0,
      shadowOpacity: 0.045
    ) {
          Button(action: onCheckIn) {
            VStack(alignment: .center, spacing: 8) {
              Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(DesignSystem.Colors.activeAction)
                .clipShape(Circle())
                .shadow(color: DesignSystem.Colors.activeAction.opacity(0.4), radius: 8, y: 4)

              Text("Log")
                .font(DesignSystem.Fonts.caption())
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.deepText)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 132)
          }
        }
    .frame(minWidth: 112)
  }

  private var flowCard: some View {
    GlassCard(
      material: .regularMaterial,
      tintOpacity: 0.36,
      borderOpacity: 1.0,
      shadowOpacity: 0.045
    ) {
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              Text("Flow")
                .font(DesignSystem.Fonts.caption())
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.softText)

              Spacer()

              // Week Navigation (same interaction style as month picker)
              HStack(spacing: 12) {
                Button(action: {
                  withAnimation {
                    if viewModel.selectedWeekIndex > 0 {
                      viewModel.selectedWeekIndex -= 1
                    }
                  }
                }) {
                  Image(systemName: "chevron.left")
                    .font(.caption.bold())
                    .foregroundColor(DesignSystem.Colors.softText)
                    .contentShape(Rectangle())
                }
                .disabled(viewModel.selectedWeekIndex == 0)
                .opacity(viewModel.selectedWeekIndex == 0 ? 0.3 : 1.0)

                Text("Week \(viewModel.selectedWeekIndex + 1) / \(viewModel.totalWeeks)")
                  .font(DesignSystem.Fonts.caption().weight(.semibold))
                  .foregroundColor(DesignSystem.Colors.deepText)
                  .frame(minWidth: 86)
                  .multilineTextAlignment(.center)

                Button(action: {
                  withAnimation {
                    if viewModel.selectedWeekIndex < max(0, viewModel.totalWeeks - 1) {
                      viewModel.selectedWeekIndex += 1
                    }
                  }
                }) {
                  Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundColor(DesignSystem.Colors.softText)
                    .contentShape(Rectangle())
                }
                .disabled(viewModel.selectedWeekIndex >= max(0, viewModel.totalWeeks - 1))
                .opacity(viewModel.selectedWeekIndex >= max(0, viewModel.totalWeeks - 1) ? 0.3 : 1.0)
              }
              .padding(.vertical, 4)
              .padding(.horizontal, 8)
              .background(Color.black.opacity(0.03))
              .clipShape(Capsule())
            }

            HStack(alignment: .bottom, spacing: 6) {
              ForEach(viewModel.weeklyStats) { stat in
                if stat.isInMonth {
                  RoundedRectangle(cornerRadius: 4)
                    .fill(stat.color)
                    .frame(height: max(20, CGFloat(stat.value * 50)))
                    .frame(maxWidth: .infinity)
                    .opacity(
                      viewModel.selectedDate != nil
                        && !Calendar.current.isDate(
                          viewModel.selectedDate!, inSameDayAs: stat.date)
                        ? 0.3 : 1.0
                    )
                    .onTapGesture {
                      withAnimation {
                        viewModel.selectDate(stat.date)
                      }
                    }
                } else {
                  Color.clear
                    .frame(height: 20)
                    .frame(maxWidth: .infinity)
                }
              }
            }
            .frame(height: 60)
          }
        }
    .frame(maxWidth: .infinity)
  }

  private var heatmapCard: some View {
    GlassCard(
      material: .regularMaterial,
      tintOpacity: 0.36,
      borderOpacity: 1.0,
      shadowOpacity: 0.045
    ) {
          MoodHeatmapView(
            entries: viewModel.filteredEntries,
            month: viewModel.currentMonth,
            selectedDate: viewModel.selectedDate,
            onSelect: { date in
              withAnimation {
                viewModel.selectDate(date)
              }
            }
          )
        }
    .frame(maxWidth: .infinity)
  }
}
