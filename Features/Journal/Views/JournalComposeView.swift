import SwiftUI

struct JournalComposeView: View {
  @Environment(\.dismiss) private var dismiss
  var onSave: (String, JournalMood) -> Void
  var initialMood: JournalMood?

  @State private var text: String = ""
  @State private var selectedMood: JournalMood = .neutral

  @FocusState private var isFocused: Bool

  var body: some View {
    NavigationStack {
      ZStack {
        DesignSystem.Colors.offWhite.ignoresSafeArea()

        ScrollView {
          VStack(spacing: 24) {
            // Mood Picker
            VStack(alignment: .leading, spacing: 12) {
              Text("How do you feel?")
                .font(DesignSystem.Fonts.headline())
                .foregroundColor(DesignSystem.Colors.softText)
                .padding(.horizontal, 4)

              ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                  ForEach(JournalMood.allCases) { mood in
                    VStack(spacing: 8) {
                      ZStack {
                        Circle()
                          .fill(selectedMood == mood ? Color(hex: mood.colorHex) : Color.clear)
                          .frame(width: 56, height: 56)

                        if selectedMood != mood {
                          Circle()
                            .stroke(Color(hex: mood.colorHex).opacity(0.3), lineWidth: 2)
                            .frame(width: 56, height: 56)
                        }

                        Image(systemName: mood.icon)
                          .font(.system(size: 24))
                          .foregroundColor(
                            selectedMood == mood ? .white : Color(hex: mood.colorHex))
                      }
                      .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                          selectedMood = mood
                        }
                      }

                      Text(mood.rawValue)
                        .font(DesignSystem.Fonts.caption())
                        .foregroundColor(
                          selectedMood == mood
                            ? DesignSystem.Colors.deepText : DesignSystem.Colors.softText)
                    }
                  }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
              }
            }
            .padding(.top, 20)

            // Text Entry
            VStack(alignment: .leading, spacing: 12) {
              Text("What's on your mind?")
                .font(DesignSystem.Fonts.headline())
                .foregroundColor(DesignSystem.Colors.softText)
                .padding(.horizontal, 4)

              ZStack(alignment: .topLeading) {
                if text.isEmpty {
                  Text("Write your thoughts here...")
                    .foregroundColor(DesignSystem.Colors.softText.opacity(0.5))
                    .padding(20)
                    .allowsHitTesting(false)
                }

                TextEditor(text: $text)
                  .font(DesignSystem.Fonts.body())
                  .foregroundColor(DesignSystem.Colors.deepText)
                  .padding(16)
                  .scrollContentBackground(.hidden)
                  .background(Color.white)
                  .cornerRadius(20)
                  .overlay(
                    RoundedRectangle(cornerRadius: 20)
                      .stroke(DesignSystem.Colors.glassBorder, lineWidth: 1)
                  )
                  .frame(minHeight: 200)
                  .focused($isFocused)
              }
            }
            .padding(.horizontal, 20)
          }
        }
      }
      .navigationTitle("New Entry")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }

        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            onSave(text, selectedMood)
            dismiss()
          }
          .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
          .fontWeight(.bold)
          .foregroundColor(DesignSystem.Colors.calmTeal)
        }
      }
      .onAppear {
        if let initial = initialMood {
          selectedMood = initial
        }
        isFocused = true
      }
    }
  }
}
