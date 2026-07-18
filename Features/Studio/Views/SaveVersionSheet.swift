import SwiftUI

struct SaveVersionSheet: View {
  @Environment(\.dismiss) private var dismiss
  var onSave: (String, String, String, String) -> Void

  @State private var title: String = ""
  @State private var note: String = ""
  @State private var selectedIcon: String = "shield.fill"
  @State private var selectedColor: String = "#50A2A7"  // Calm Teal default

  let icons = [
    "shield.fill", "star.fill", "bookmark.fill", "flag.fill",
    "heart.fill", "bell.fill", "tag.fill", "doc.text.fill",
    "exclamationmark.triangle.fill", "checkmark.circle.fill",
  ]

  let colors = [
    "#50A2A7",  // Calm Teal
    "#E49A89",  // Warm Coral
    "#4A4A4A",  // Deep Charcoal
    "#8B5FBF",  // Purple
    "#E0C068",  // Gold
    "#559E54",  // Green
    "#D9534F",  // Red
  ]

  var body: some View {
    NavigationStack {
      Form {
        Section(header: Text("Version Info")) {
          TextField("Version Name (e.g., 'Draft 1')", text: $title)
          TextField("Note (Optional)", text: $note)
        }

        Section(header: Text("Icon")) {
          LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
            ForEach(icons, id: \.self) { icon in
              Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(
                  selectedIcon == icon ? Color(hex: selectedColor) : .gray.opacity(0.3)
                )
                .padding(8)
                .background(
                  Circle()
                    .fill(
                      selectedIcon == icon ? Color(hex: selectedColor).opacity(0.1) : Color.clear)
                )
                .onTapGesture {
                  selectedIcon = icon
                }
            }
          }
          .padding(.vertical, 8)
        }

        Section(header: Text("Color")) {
          LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
            ForEach(colors, id: \.self) { colorHex in
              Circle()
                .fill(Color(hex: colorHex))
                .frame(width: 32, height: 32)
                .overlay(
                  Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .opacity(selectedColor == colorHex ? 1 : 0)
                )
                .overlay(
                  Circle()
                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
                )
                .onTapGesture {
                  selectedColor = colorHex
                }
            }
          }
          .padding(.vertical, 8)
        }
      }
      .navigationTitle("Save Version")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            onSave(title, note, selectedIcon, selectedColor)
            dismiss()
          }

        }
      }
    }
  }
}
