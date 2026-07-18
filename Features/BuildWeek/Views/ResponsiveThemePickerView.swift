import SwiftUI

struct ResponsiveThemePickerView: View {
  @Environment(SettingsStore.self) private var settings
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      ZStack {
        settings.selectedTheme.shelterPalette.backgroundBottom
          .ignoresSafeArea()

        ScrollView {
          VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
              Text("Choose your Reset")
                .font(.largeTitle.weight(.semibold))
                .fontDesign(.serif)
                .foregroundStyle(settings.selectedTheme.shelterPalette.primaryText)

              Text("Pick the atmosphere for the two-minute Reset. Home and Shield never change.")
                .font(.body)
                .foregroundStyle(settings.selectedTheme.shelterPalette.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            }

            ForEach(AppTheme.allCases) { theme in
              themeChoice(theme)
            }

            Label(
              "Home stays light. Shield stays static and high contrast.",
              systemImage: "shield.fill"
            )
            .font(.footnote.weight(.semibold))
            .foregroundStyle(settings.selectedTheme.shelterPalette.secondaryText)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityElement(children: .combine)
          }
          .padding(20)
          .padding(.bottom, 24)
        }
      }
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") { dismiss() }
            .font(.body.weight(.semibold))
            .foregroundStyle(settings.selectedTheme.shelterPalette.primaryText)
            .frame(minWidth: 44, minHeight: 44)
        }
      }
      .toolbarBackground(settings.selectedTheme.shelterPalette.backgroundTop, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
    }
    .preferredColorScheme(.dark)
  }

  private func themeChoice(_ theme: AppTheme) -> some View {
    let palette = theme.shelterPalette
    let isSelected = settings.selectedTheme == theme

    return Button {
      settings.selectedTheme = theme
    } label: {
      ZStack(alignment: .bottomLeading) {
        ResponsiveShelterField(theme: theme, mode: .resting, isAnimated: false)

        LinearGradient(
          colors: [Color.clear, Color.black.opacity(0.68)],
          startPoint: .top,
          endPoint: .bottom
        )

        HStack(alignment: .bottom, spacing: 14) {
          VStack(alignment: .leading, spacing: 5) {
            Label(theme.displayName, systemImage: theme.symbolName)
              .font(.title3.weight(.semibold))
              .foregroundStyle(palette.primaryText)

            Text(theme.detail)
              .font(.footnote)
              .foregroundStyle(palette.secondaryText)
              .fixedSize(horizontal: false, vertical: true)
          }

          Spacer(minLength: 8)

          Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .font(.system(size: 26, weight: .semibold))
            .foregroundStyle(isSelected ? palette.accent : palette.primaryText)
            .accessibilityHidden(true)
        }
        .padding(18)
      }
      .frame(maxWidth: .infinity)
      .frame(minHeight: 176)
      .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
          .stroke(
            isSelected ? palette.accent : palette.surfaceBorder,
            lineWidth: isSelected ? 2 : 1
          )
      }
    }
    .buttonStyle(.plain)
    .accessibilityLabel("\(theme.displayName) theme")
    .accessibilityValue(isSelected ? "Selected" : "Not selected")
    .accessibilityHint("Changes only the two-minute Reset")
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }
}

#Preview {
  ResponsiveThemePickerView()
    .environment(SettingsStore())
}
