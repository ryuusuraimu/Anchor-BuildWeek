import SwiftUI

#if canImport(UIKit)
  import UIKit
#endif

struct HomeView: View {
  @Binding var selectedTab: AppTab
  @State private var viewModel = HomeViewModel()
  @Environment(SettingsStore.self) private var settings
  // [NEW] Support Contact Store
  @EnvironmentObject var contactStore: EmergencyContactStore

  @AppStorage("didDismissLockScreenCardTip") private var didDismissLockScreenCardTip = false

  @State private var showShield = false
  @State private var showBreathing = false
  @State private var deployButtonHeight: CGFloat = 0

  @State private var showLockScreenCardTip = false

  // Phase 2: Active Supporter
  @State private var showCallConfirmation = false
  @State private var showBackTapGuide = false
  @State private var showActionButtonGuide = false

  // Support Contact modal flow: keep exactly one modal active at a time.
  // This avoids ContactsUI view-service timeouts that can happen with nested
  // modal presentations (e.g., presenting the system contact picker from inside
  // an already-presented sheet).
  @State private var contactDraft = EmergencyContactDraft()
  @State private var contactSheet: ContactSheet?

  enum ContactSheet: Identifiable {
    case editor
    case picker

    var id: Int {
      switch self {
      case .editor: return 1
      case .picker: return 2
      }
    }
  }

  var body: some View {
    NavigationStack {
      ZStack {
        // 1. Premium Animated Background
        OrganicBackgroundView(colors: [
          DesignSystem.Colors.calmTeal.opacity(0.15),
          DesignSystem.Colors.warmCoral.opacity(0.12),
        ])

        ScrollView {
          VStack(spacing: DesignSystem.Layout.sectionSpacing) {
            // A. Hero
            HomeHeroView(
              readinessScore: viewModel.readinessScore)

            // A2. Today's Anchor (Restored & Refined)
            GlassCard {
              VStack(alignment: .leading, spacing: 12) {
                HStack {
                  Image(systemName: "sun.max.fill")
                    .foregroundColor(DesignSystem.Colors.warmCoral)
                  Text("Today’s Anchor")
                    .font(DesignSystem.Fonts.caption())
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.softText)
                }

                ViewThatFits(in: .horizontal) {
                  todayAnchorContent(axis: .horizontal)
                  todayAnchorContent(axis: .vertical)
                }
              }
            }
            .padding(.horizontal, DesignSystem.Layout.screenPadding)

            // B. Dashboard Widget
            HomeDashboardView(
              shieldScore: viewModel.shieldScore,
              supporterScore: viewModel.supporterScore,
              practiceScore: viewModel.practiceScore,
              onTapShield: { selectedTab = .studio },
              onTapSupporter: { /* No-op or scroll to card */  },
              onTapJournal: { selectedTab = .journal }
            )
            .padding(.top, -16)  // Pull up slightly closer to hero if needed

            // C. Support Contact Card
            EmergencyContactCard(
              store: contactStore,
              onAdd: { openContactEditor(editing: false) },
              onEdit: { contact in openContactEditor(contact) },
              onPick: { openContactPicker() }
            )
            .padding(.horizontal, DesignSystem.Layout.screenPadding)

            // D. Deploy Shield (Bottom)
            VStack(spacing: 12) {
              // Pulse Animation Layer
              ZStack {
                Circle()
                  .fill(DesignSystem.Colors.calmTeal.opacity(0.3))
                  .frame(width: 80, height: 80)
                  .scaleEffect(1.2)
                  .opacity(0.5)
                  .blur(radius: 20)
              }

              DeployShieldButton(showShield: showShield) {
                showShield = true
              }
              .background(
                GeometryReader { proxy in
                  Color.clear
                    .preference(key: DeployButtonHeightPreferenceKey.self, value: proxy.size.height)
                }
              )

              TipQuickAccessCard(
                height: deployButtonHeight,
                onBackTap: { showBackTapGuide = true },
                onActionButton: { showActionButtonGuide = true }
              )

              if !didDismissLockScreenCardTip {
                TipLockScreenCard(
                  onLearnMore: { showLockScreenCardTip = true },
                  onDismiss: { didDismissLockScreenCardTip = true }
                )
              }
            }
            .padding(.horizontal, DesignSystem.Layout.screenPadding)
            .padding(.bottom, 40)
          }
        }
        .ignoresSafeArea(edges: .top)
      }
      .buttonStyle(.plain)
      .onPreferenceChange(DeployButtonHeightPreferenceKey.self) { value in
        if value > 0 {
          deployButtonHeight = value
        }
      }

      .onAppear {
        viewModel.checkReadiness(settings: settings)
      }
      .fullScreenCover(isPresented: $showShield) {
        ShieldView()
      }
      .sheet(isPresented: $showBackTapGuide) {
        BackTapGuideView()
      }
      .sheet(isPresented: $showActionButtonGuide) {
        ActionButtonGuideView()
      }
      .sheet(isPresented: $showLockScreenCardTip) {
        LockScreenCardTipSheet()
      }
      .fullScreenCover(isPresented: $showBreathing) {
        BreathingView()
      }
      // MARK: - Support Contact Sheets (single modal)
      .sheet(item: $contactSheet) { sheet in
        switch sheet {
        case .editor:
          NavigationStack {
            EmergencyContactEditor(
              draft: $contactDraft,
              isEditing: contactDraft.id != nil,
              onPickFromContacts: {
                contactSheet = .picker
              },
              onSave: {
                contactStore.upsert(contactDraft.toEmergencyContact())
                contactSheet = nil
              },
              onCancel: {
                contactSheet = nil
              },
              onRemove: (contactDraft.id != nil)
                ? {
                  if let id = contactDraft.id {
                    contactStore.remove(id: id)
                  }
                  contactSheet = nil
                } : nil
            )
          }

        case .picker:
          ContactPicker(
            onSelect: { name, phone, label in
              contactDraft.name = name
              contactDraft.phone = phone
              contactDraft.phoneLabel = label ?? ""

              contactStore.upsert(contactDraft.toEmergencyContact())

              // Close sheet
              contactSheet = nil
            },
            onCancel: {
              contactSheet = .editor
            }
          )
        }
      }
      .task {
        viewModel.checkReadiness(settings: settings)
      }
      .onChange(of: contactStore.contacts) { _, newContacts in
        viewModel.checkReadiness(contacts: newContacts, settings: settings)
      }

      // MARK: - Helpers
      // (kept inside the view so it remains easy to reason about modal state)
    }
  }

  private func openContactEditor(editing: Bool) {
    contactDraft = EmergencyContactDraft(from: editing ? contactStore.contact : nil)
    contactSheet = .editor
  }

  private func openContactEditor(_ contact: EmergencyContact) {
    contactDraft = EmergencyContactDraft(from: contact)
    contactSheet = .editor
  }

  private func openContactPicker() {
    // Ensure a clean switch: one modal at a time.
    contactDraft = EmergencyContactDraft(from: nil)
    contactSheet = .picker
  }

  private func saveDraftToStore() {
    let trimmedName = contactDraft.name.trimmingCharacters(in: .whitespacesAndNewlines)
    let trimmedPhone = contactDraft.phone.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !trimmedName.isEmpty, !trimmedPhone.isEmpty else { return }

    contactStore.upsert(EmergencyContact(
      name: trimmedName,
      phone: trimmedPhone,
      note: contactDraft.note.trimmingCharacters(in: .whitespacesAndNewlines)
    ))
  }

  private func clearContact() {
    contactStore.clear()
  }

  @ViewBuilder
  private func todayAnchorContent(axis: Axis) -> some View {
    let isHorizontal = axis == .horizontal
    let imageSize: CGFloat = isHorizontal ? 74 : 96

    Group {
      if isHorizontal {
        HStack(alignment: .top, spacing: 16) {
          todayAnchorImage(size: imageSize)
          todayAnchorCopy
          Spacer(minLength: 0)
        }
      } else {
        VStack(alignment: .leading, spacing: 12) {
          todayAnchorImage(size: imageSize)
          todayAnchorCopy
        }
      }
    }
  }

  private func todayAnchorImage(size: CGFloat) -> some View {
    Image("AnchorCalmIllustration", bundle: .module)
      .resizable()
      .scaledToFill()
      .frame(width: size, height: size)
      .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
      .overlay(
        RoundedRectangle(cornerRadius: 18, style: .continuous)
          .stroke(Color.white.opacity(0.72), lineWidth: 1)
      )
      .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
      .accessibilityHidden(true)
  }

  private var todayAnchorCopy: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("Morning Breathing")
        .font(DesignSystem.Fonts.title())
        .foregroundColor(DesignSystem.Colors.deepText)
        .fixedSize(horizontal: false, vertical: true)

      Text("Take two minutes to settle your breath before the day begins.")
        .font(DesignSystem.Fonts.body())
        .foregroundColor(DesignSystem.Colors.softText)
        .fixedSize(horizontal: false, vertical: true)

      Button(action: {
        showBreathing = true
      }) {
        Text("Start Session")
          .font(DesignSystem.Fonts.body())
          .foregroundColor(DesignSystem.Colors.calmTeal)
          .padding(.top, 4)
      }
    }
  }
}

private struct DeployButtonHeightPreferenceKey: PreferenceKey {
  static let defaultValue: CGFloat = 0

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = max(value, nextValue())
  }
}

private struct TipQuickAccessCard: View {
  let height: CGFloat
  let onBackTap: () -> Void
  let onActionButton: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Tip")
        .font(DesignSystem.Fonts.caption())
        .fontWeight(.bold)
        .foregroundColor(.black)

      ViewThatFits(in: .horizontal) {
        quickAccessButtons(axis: .horizontal)
        quickAccessButtons(axis: .vertical)
      }
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 10)
    .frame(maxWidth: .infinity)
    .frame(minHeight: max(74, height > 0 ? min(height, 96) : 74))
    .background(Color.clear)
    .overlay(
      RoundedRectangle(cornerRadius: 14)
        .stroke(Color.black, lineWidth: 1.5)
    )
  }

  @ViewBuilder
  private func quickAccessButtons(axis: Axis) -> some View {
    let stackSpacing: CGFloat = axis == .horizontal ? 12 : 8

    Group {
      if axis == .horizontal {
        HStack(alignment: .top, spacing: stackSpacing) {
          backTapButton
          actionButton
        }
      } else {
        VStack(alignment: .center, spacing: stackSpacing) {
          backTapButton
          actionButton
        }
      }
    }
  }

  private var backTapButton: some View {
        Button(action: onBackTap) {
          VStack(alignment: .center, spacing: 4) {
            Image(systemName: "hand.tap.fill")
              .font(.body)
            Text("Setup Back Tap")
              .font(DesignSystem.Fonts.caption())
              .multilineTextAlignment(.center)
              .lineLimit(2)
          }
          .frame(maxWidth: .infinity)
          .foregroundColor(.black)
        }
        .buttonStyle(.plain)
        .frame(minHeight: DesignSystem.Layout.minTouchTarget)
  }

  private var actionButton: some View {
        Button(action: onActionButton) {
          VStack(alignment: .center, spacing: 4) {
            Image(systemName: "button.programmable")
              .font(.body)
            Text("Setup Action Button")
              .font(DesignSystem.Fonts.caption())
              .multilineTextAlignment(.center)
              .lineLimit(2)
          }
          .frame(maxWidth: .infinity)
          .foregroundColor(.black)
        }
        .buttonStyle(.plain)
        .frame(minHeight: DesignSystem.Layout.minTouchTarget)
  }
}

@MainActor
private enum LockScreenTipCopy {
  static var blurb: String {
    if RuntimeEnvironment.isSimulator && RuntimeEnvironment.isIPhone {
      return
        "Shield shows the instructions on the lock screen (Now Playing). iPhone Simulator may not show it reliably — verify on a real iPhone."
    }
    return "Shield shows the instructions on the lock screen (Now Playing)."
  }

  static var note: String? {
    guard RuntimeEnvironment.isSimulator else { return nil }
    if RuntimeEnvironment.isIPhone {
      return
        "Note: iPhone Simulator may not show the lock screen / Now Playing UI reliably (even when Safari plays video). This is a simulator limitation — the feature is verified on a real iPhone."
    }
    return
      "Note: Simulator behavior varies by device type and OS version. It may work on iPad Simulator, but iPhone Simulator often doesn't show it reliably. Verify on a real iPhone."
  }
}

private struct TipLockScreenCard: View {
  let onLearnMore: () -> Void
  let onDismiss: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("Tip")
          .font(DesignSystem.Fonts.caption())
          .fontWeight(.bold)
          .foregroundColor(.black)

        Spacer()

        Button(action: onDismiss) {
          Image(systemName: "xmark")
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.black.opacity(0.65))
            .padding(6)
            .background(Color.black.opacity(0.06), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Dismiss")
      }

      HStack(alignment: .top, spacing: 12) {
        Image(systemName: "lock.fill")
          .font(.system(size: 18, weight: .semibold))
          .foregroundColor(.black.opacity(0.8))

        VStack(alignment: .leading, spacing: 4) {
          Text("Lock Screen Card")
            .font(DesignSystem.Fonts.body())
            .fontWeight(.semibold)
            .foregroundColor(.black)

          Text(LockScreenTipCopy.blurb)
            .font(DesignSystem.Fonts.caption())
            .foregroundColor(.black.opacity(0.65))
            .fixedSize(horizontal: false, vertical: true)
        }

        Spacer(minLength: 0)

        Button(action: onLearnMore) {
          Text("How")
            .font(DesignSystem.Fonts.caption())
            .fontWeight(.bold)
            .foregroundColor(DesignSystem.Colors.activeAction)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.06), in: Capsule())
        }
        .buttonStyle(.plain)
      }
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 10)
    .frame(maxWidth: .infinity)
    .background(Color.clear)
    .overlay(
      RoundedRectangle(cornerRadius: 14)
        .stroke(Color.black, lineWidth: 1.5)
    )
  }
}

private struct LockScreenCardTipSheet: View {
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      ZStack {
        OrganicBackgroundView()
          .ignoresSafeArea()

        ScrollView {
          VStack(alignment: .leading, spacing: 16) {
            GlassCard {
              VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                  Image(systemName: "lock.fill")
                    .foregroundColor(DesignSystem.Colors.calmTeal)
                  Text("Lock Screen Card")
                    .font(DesignSystem.Fonts.headline())
                    .foregroundColor(DesignSystem.Colors.deepText)
                  Spacer()
                }

                Text(
                  "When Shield is running, Anchor keeps a small \"Now Playing\" session active so the lock screen can display the support instructions + QR."
                )
                .font(DesignSystem.Fonts.body())
                .foregroundColor(DesignSystem.Colors.softText)

                Divider().opacity(0.35)

                VStack(alignment: .leading, spacing: 8) {
                  Text("How to verify")
                    .font(DesignSystem.Fonts.caption())
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.deepText)
                    .textCase(.uppercase)

                  TipStepRow(number: "1", text: "Run Anchor on a real iPhone.")
                  TipStepRow(number: "2", text: "Open Home → Deploy Shield.")
                  TipStepRow(
                    number: "3", text: "Lock the phone. The card appears on the lock screen.")
                  TipStepRow(
                    number: "4", text: "Use Next/Previous controls on the card to switch steps.")
                }

                Divider().opacity(0.35)

                if let note = LockScreenTipCopy.note {
                  Text(note)
                    .font(DesignSystem.Fonts.caption())
                    .foregroundColor(DesignSystem.Colors.softText)
                }
              }
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
          }
          .padding(.bottom, 24)
        }
      }
      .navigationTitle("Tip")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") { dismiss() }
            .font(DesignSystem.Fonts.body())
            .foregroundColor(DesignSystem.Colors.calmTeal)
        }
      }
    }
  }
}

private struct TipStepRow: View {
  let number: String
  let text: String

  var body: some View {
    HStack(alignment: .top, spacing: 10) {
      Text(number)
        .font(DesignSystem.Fonts.caption())
        .fontWeight(.bold)
        .foregroundColor(.white)
        .frame(width: 22, height: 22)
        .background(DesignSystem.Colors.calmTeal, in: Circle())

      Text(text)
        .font(DesignSystem.Fonts.body())
        .foregroundColor(DesignSystem.Colors.deepText)

      Spacer(minLength: 0)
    }
  }
}

#Preview {
  HomeView(selectedTab: .constant(.home))
    .environment(SettingsStore())
    .environmentObject(EmergencyContactStore())
}
