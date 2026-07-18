import Observation
import SwiftUI

struct SettingsView: View {
  @Environment(SettingsStore.self) private var settings
  @EnvironmentObject private var contactStore: EmergencyContactStore
  @Environment(\.dismiss) private var dismiss
  @State private var currentIconName: String? = UIApplication.shared.alternateIconName
  @State private var infoSheet: SettingsInfoSheet?
  @State private var showClearLocalDataConfirmation = false
  @State private var showClearLocalDataResult = false

  var body: some View {
    NavigationStack {
      List {
        Section("Appearance") {
          Picker("Theme", selection: Bindable(settings).selectedTheme) {
            ForEach(AppTheme.allCases) { theme in
              Text(theme.displayName).tag(theme)
            }
          }

          Text("Appearance changes Home and Reset only. Shield stays static and high contrast.")
            .font(.footnote)
            .foregroundStyle(.secondary)
        }

        Section("Shield Card") {
          Toggle("Brighten Shield Card", isOn: Bindable(settings).increaseBrightnessOnShieldCard)
          Toggle("Keep Screen Awake", isOn: Bindable(settings).preventScreenSleepOnShieldCard)
        }

        Section("About Anchor") {
          Button {
            infoSheet = .privacy
          } label: {
            SettingsInfoRow(
              icon: "hand.raised",
              title: "Privacy",
              subtitle: "Local-first storage and optional Contacts access"
            )
          }

          Button {
            infoSheet = .limits
          } label: {
            SettingsInfoRow(
              icon: "exclamationmark.shield",
              title: "Important Note",
              subtitle: "Communication aid, not medical or emergency service"
            )
          }
        }

        Section("Data") {
          Button(role: .destructive) {
            showClearLocalDataConfirmation = true
          } label: {
            SettingsInfoRow(
              icon: "trash",
              title: "Clear Local Data",
              subtitle: "Remove your Shield card, journal, support relay, history, and preferences"
            )
          }
        }

        Section("App Icon") {
          // Default
          Button {
            changeIcon(to: nil)
          } label: {
            IconRow(name: "Default (Teal)", iconName: nil, imagePath: "Preview-Default")
          }

          // Orange (AppIcon-3)
          Button {
            changeIcon(to: "AppIcon-3")
          } label: {
            IconRow(name: "Orange", iconName: "AppIcon-3", imagePath: "Preview-3")
          }

          // Black (AppIcon-2 / 2.png)
          Button {
            changeIcon(to: "AppIcon-2")
          } label: {
            IconRow(name: "Black", iconName: "AppIcon-2", imagePath: "Preview-2")
          }
        }
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .alert("App Icon", isPresented: $showIconAlert) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(iconAlertMessage)
      }
      .confirmationDialog(
        "Clear all local Anchor data?",
        isPresented: $showClearLocalDataConfirmation,
        titleVisibility: .visible
      ) {
        Button("Clear Local Data", role: .destructive) {
          clearLocalData()
        }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text("This removes data stored on this device, including your Shield card, journal entries, support relay contacts, saved versions, and preferences.")
      }
      .alert("Local Data Cleared", isPresented: $showClearLocalDataResult) {
        Button("OK", role: .cancel) {}
      } message: {
        Text("Anchor has reset local data on this device.")
      }
      .scrollContentBackground(.hidden)
      .background(settings.selectedTheme.backgroundColor)
      .sheet(item: $infoSheet) { sheet in
        SettingsInfoDetail(sheet: sheet)
      }
    }
  }

  @State private var showIconAlert = false
  @State private var iconAlertMessage = ""

  private func changeIcon(to iconName: String?) {
    guard UIApplication.shared.supportsAlternateIcons else {
      iconAlertMessage = "This device does not support alternate icons."
      showIconAlert = true
      return
    }

    UIApplication.shared.setAlternateIconName(iconName) { error in
      DispatchQueue.main.async {
        if let error = error {
          self.iconAlertMessage = "Failed to change icon: \(error.localizedDescription)"
        } else {
          self.currentIconName = iconName
          self.iconAlertMessage = "App icon updated successfully!"
        }
        self.showIconAlert = true
      }
    }
  }

  private func clearLocalData() {
    ShieldStorage.shared.resetToDefaults()
    JournalStorage.shared.clearAll()
    contactStore.clear()
    ShieldVoiceLibrary.shared.clearAllCachedAudio()
    settings.resetForLocalDataClear()
    currentIconName = UIApplication.shared.alternateIconName
    showClearLocalDataResult = true
  }

  @ViewBuilder
  private func IconRow(name: String, iconName: String?, imagePath: String) -> some View {
    HStack {
      if let uiImage = loadIconImage(named: imagePath) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFit()
          .frame(width: 48, height: 48)
          .cornerRadius(10)
          .shadow(radius: 1)
      } else {
        RoundedRectangle(cornerRadius: 10)
          .fill(Color.gray.opacity(0.3))
          .frame(width: 48, height: 48)
          .overlay(Text("?"))
      }

      Text(name)
        .foregroundColor(.primary)
        .padding(.leading, 8)

      Spacer()

      if currentIconName == iconName {
        Image(systemName: "checkmark")
          .foregroundColor(.accentColor)
      }
    }
  }

  private func loadIconImage(named name: String) -> UIImage? {
    // 1. Asset Catalog
    if let img = UIImage(named: name) { return img }

    // 2. Resource File Fallback (e.g. "1.png" mapping)
    // Map preview names to filenames
    let filename: String? = {
      switch name {
      case "Preview-1": return "1.png"
      case "Preview-2": return "2.png"
      case "Preview-3": return "3.png"
      // Note: Default icon is tricky to load by file if it's in AppIcon.appiconset
      // We can fallback to "ReportLogo" logic for default
      case "Preview-Default": return nil
      default: return nil
      }
    }()

    if let fname = filename {
      if let img = UIImage(named: fname) { return img }
      if let url = Bundle.main.url(forResource: fname, withExtension: nil),
        let data = try? Data(contentsOf: url),
        let img = UIImage(data: data)
      {
        return img
      }
    }

    // 3. Fallback for Default using ReportLogo
    if name == "Preview-Default" {
      return UIImage(named: "ReportLogo")
    }

    return nil
  }
}

private enum SettingsInfoSheet: Identifiable {
  case privacy
  case limits

  var id: String {
    switch self {
    case .privacy: return "privacy"
    case .limits: return "limits"
    }
  }

  var title: String {
    switch self {
    case .privacy: return "Privacy"
    case .limits: return "Important Note"
    }
  }
}

private struct SettingsInfoRow: View {
  let icon: String
  let title: String
  let subtitle: String

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 17, weight: .semibold))
        .foregroundStyle(DesignSystem.Colors.activeAction)
        .frame(width: 28, height: 28)
        .background(
          Circle()
            .fill(DesignSystem.Colors.calmTeal.opacity(0.12))
        )

      VStack(alignment: .leading, spacing: 3) {
        Text(title)
          .font(DesignSystem.Fonts.body())
          .foregroundStyle(.primary)
        Text(subtitle)
          .font(DesignSystem.Fonts.caption())
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer(minLength: 8)

      Image(systemName: "chevron.right")
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(.tertiary)
    }
    .contentShape(Rectangle())
    .accessibilityElement(children: .combine)
  }
}

private struct SettingsInfoDetail: View {
  let sheet: SettingsInfoSheet
  @Environment(\.dismiss) private var dismiss

  private struct InfoItem: Identifiable {
    let id = UUID()
    let title: String
    let body: String
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 18) {
          ForEach(items) { item in
            VStack(alignment: .leading, spacing: 6) {
              Text(item.title)
                .font(DesignSystem.Fonts.headline())
                .foregroundStyle(DesignSystem.Colors.deepText)
              Text(item.body)
                .font(DesignSystem.Fonts.body())
                .foregroundStyle(DesignSystem.Colors.softText)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
              RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.72))
            )
            .overlay(
              RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
            )
          }
        }
        .padding(20)
      }
      .background(
        LinearGradient(
          colors: [DesignSystem.Colors.offWhite, DesignSystem.Colors.paleMint],
          startPoint: .top,
          endPoint: .bottom
        )
        .ignoresSafeArea()
      )
      .navigationTitle(sheet.title)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") { dismiss() }
        }
      }
    }
  }

  private var items: [InfoItem] {
    switch sheet {
    case .privacy:
      return [
        InfoItem(
          title: "Local by default",
          body: "Your support card, journal entries, and support relay contacts are stored on this device."
        ),
        InfoItem(
          title: "Contacts are optional",
          body: "Anchor asks for Contacts access only if you choose to pick trusted support contacts."
        ),
        InfoItem(
          title: "No account required",
          body: "Anchor does not require sign-in for the first release."
        ),
      ]
    case .limits:
      return [
        InfoItem(
          title: "Communication support",
          body: "Anchor helps you prepare short instructions for moments when speaking is hard."
        ),
        InfoItem(
          title: "Not medical care",
          body: "Anchor does not diagnose, treat, monitor, or provide medical advice."
        ),
        InfoItem(
          title: "Not emergency service",
          body: "If you are in immediate danger or need urgent help, contact local emergency services or someone nearby."
        ),
      ]
    }
  }
}
