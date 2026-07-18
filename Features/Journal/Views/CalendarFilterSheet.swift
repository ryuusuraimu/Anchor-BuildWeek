import SwiftUI

struct CalendarFilterSheet: View {
  @Environment(\.dismiss) private var dismiss
  @Binding var selectedDate: Date?

  @State private var tempDate: Date = Date()

  var body: some View {
    NavigationStack {
      VStack(spacing: 24) {
        DatePicker(
          "Select Date",
          selection: $tempDate,
          displayedComponents: .date
        )
        .datePickerStyle(.graphical)
        .accentColor(DesignSystem.Colors.calmTeal)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
        .padding(.horizontal)

        Button(action: {
          selectedDate = tempDate
          dismiss()
        }) {
          Text("Show Entries for Date")
            .font(DesignSystem.Fonts.headline())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(DesignSystem.Colors.calmTeal)
            .cornerRadius(16)
        }
        .padding(.horizontal)

        if selectedDate != nil {
          Button("Clear Filter") {
            selectedDate = nil
            dismiss()
          }
          .foregroundColor(DesignSystem.Colors.softText)
        }

        Spacer()
      }
      .padding(.top, 24)
      .background(DesignSystem.Colors.offWhite.ignoresSafeArea())
      .navigationTitle("Filter by Date")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Close") { dismiss() }
        }
      }
      .onAppear {
        if let current = selectedDate {
          tempDate = current
        }
      }
    }
    .presentationDetents([.medium])
  }
}
