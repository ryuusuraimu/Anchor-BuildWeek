import SwiftUI

struct HistoryView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var history: [ShieldStorage.HistoryItem] = []
  var onRestore: (ShieldStorage.HistoryItem) -> Void

  var body: some View {
    NavigationStack {
      ZStack {
        // Background
        DesignSystem.Colors.offWhite.ignoresSafeArea()

        if history.isEmpty {
          VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
              .font(.system(size: 48))
              .foregroundColor(DesignSystem.Colors.softText)
            Text("No History Yet")
              .font(DesignSystem.Fonts.headline())
              .foregroundColor(DesignSystem.Colors.softText)
            Text("Changes you save will appear here.")
              .font(DesignSystem.Fonts.caption())
              .foregroundColor(DesignSystem.Colors.softText.opacity(0.8))
          }
        } else {
          List {
            ForEach(history) { item in
              Button(action: {
                onRestore(item)
                dismiss()
              }) {
                HStack(alignment: .top, spacing: 16) {
                  // Icon based on Custom or default
                  ZStack {
                    Circle()
                      .fill(
                        item.themeColor != nil
                          ? Color(hex: item.themeColor!).opacity(0.1)
                          : DesignSystem.Colors.calmTeal.opacity(0.1)
                      )
                      .frame(width: 40, height: 40)

                    Image(
                      systemName: item.icon ?? "text.bubble.fill"
                    )
                    .foregroundColor(
                      item.themeColor != nil
                        ? Color(hex: item.themeColor!)
                        : DesignSystem.Colors.calmTeal
                    )
                  }

                  VStack(alignment: .leading, spacing: 4) {
                    HStack {
                      if let title = item.title, !title.isEmpty {
                        Text(title)
                          .font(DesignSystem.Fonts.headline())
                          .foregroundColor(DesignSystem.Colors.deepText)
                      } else {
                        Text(item.date.formatted(date: .abbreviated, time: .shortened))
                          .font(DesignSystem.Fonts.caption())
                          .foregroundColor(DesignSystem.Colors.softText)
                      }

                      Spacer()
                    }

                    if let note = item.note {
                      Text(note)
                        .font(DesignSystem.Fonts.caption())
                        .foregroundColor(
                          item.themeColor != nil
                            ? Color(hex: item.themeColor!)
                            : DesignSystem.Colors.calmTeal
                        )
                        .padding(.bottom, 2)
                    } else if item.title != nil {
                      // If there's a title but no note, show date as subtitle
                      Text(item.date.formatted(date: .abbreviated, time: .shortened))
                        .font(DesignSystem.Fonts.caption())
                        .foregroundColor(DesignSystem.Colors.softText)
                    }

                    Text(item.config.situationText)
                      .font(DesignSystem.Fonts.body())
                      .foregroundColor(DesignSystem.Colors.deepText)
                      .lineLimit(2)
                  }
                }
                .padding(.vertical, 8)
              }
              .listRowBackground(Color.clear)
              .listRowSeparator(.hidden)
              .background(
                RoundedRectangle(cornerRadius: 12)
                  .fill(Color.white.opacity(0.6))
                  .padding(.vertical, 4)
              )
              .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                  withAnimation {
                    ShieldStorage.shared.deleteHistoryItem(id: item.id)
                    history.removeAll { $0.id == item.id }
                  }
                } label: {
                  Label("Delete", systemImage: "trash")
                }
              }
            }
          }
          .listStyle(.plain)
          .scrollContentBackground(.hidden)
        }
      }
      .navigationTitle("History")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") {
            dismiss()
          }
          .foregroundColor(DesignSystem.Colors.calmTeal)
        }
      }
      .onAppear {
        history = ShieldStorage.shared.loadHistory()
      }
    }
  }
}
